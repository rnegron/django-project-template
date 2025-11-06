#!/usr/bin/env bash
#
# Template Integration Test Script
#
# Tests the Django project template by creating a real project and running validation steps.
#
# Usage:
#   ./test_template.sh [OPTIONS]
#
# Options:
#   --full              Full test suite (includes Docker, linting, type checks)
#   --quick             Quick mode (skips migrations, static files, Docker)
#   --docker-only       Only run Docker tests
#   --skip-migrations   Skip migration tests
#   --skip-static       Skip static file collection
#   --skip-docker       Skip Docker tests
#   --help              Show this help

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

TEST_PROJECT_NAME="test_project_$$"
TEST_DIR="/tmp/${TEST_PROJECT_NAME}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test execution flags
SKIP_MIGRATIONS=false
SKIP_STATIC=false
SKIP_DOCKER=true
RUN_LINTING=false
RUN_TYPECHECK=false
DOCKER_ONLY=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo ""
    log_info "$1"
}

cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        log_info "Cleaning up test project at $TEST_DIR"
        rm -rf "$TEST_DIR"
    fi
}

show_help() {
    head -n 18 "$0" | grep "^#" | sed 's/^# \?//'
    exit 0
}

# ============================================================================
# Test Functions
# ============================================================================

create_project() {
    log_step "Creating project from template"

    mkdir -p "$TEST_DIR"

    django-admin startproject \
        --template="$TEMPLATE_DIR" \
        --name=docker-entrypoint.sh,.isort.cfg,pytest.ini \
        --extension=py,md,toml \
        --exclude=node_modules \
        "$TEST_PROJECT_NAME" \
        "$TEST_DIR"

    if [[ ! -d "$TEST_DIR" ]]; then
        log_error "Project creation failed"
        exit 1
    fi

    log_info "✓ Project created successfully"
    cd "$TEST_DIR"
}

verify_files() {
    log_step "Verifying essential files"

    local essential_files=(
        "manage.py"
        "pyproject.toml"
        "pytest.ini"
        "docker-compose.yml"
        "Dockerfile"
        ".env.example"
        "config/settings/base.py"
        "config/settings/local.py"
        "config/settings/production.py"
        "config/settings/test.py"
        "$TEST_PROJECT_NAME/users/models.py"
    )

    for file in "${essential_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Missing file: $file"
            exit 1
        fi
    done

    log_info "✓ All essential files present"
}

verify_template_substitution() {
    log_step "Verifying template variable substitution"

    if grep -r "{{ project_name }}" . \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude="*.pyc" \
        --exclude="test_template.sh" > /dev/null 2>&1; then
        log_error "Found unreplaced template variables"
        grep -r "{{ project_name }}" . \
            --exclude-dir=.git \
            --exclude-dir=node_modules \
            --exclude="*.pyc" \
            --exclude="test_template.sh" || true
        exit 1
    fi

    log_info "✓ Template variables replaced correctly"
}

setup_environment() {
    log_step "Setting up environment"

    cp .env.example .env
    cat >> .env << EOF
SECRET_KEY=test-secret-key-for-testing-only
DATABASE_URL=sqlite:///db.sqlite3
EOF

    log_info "✓ Environment configured"
}

install_dependencies() {
    log_step "Installing dependencies"

    if command -v uv &> /dev/null; then
        uv sync --all-groups
        source .venv/bin/activate
    else
        log_warn "uv not found, falling back to pip"
        python -m venv .venv
        source .venv/bin/activate
        pip install -e ".[dev]"
    fi

    log_info "✓ Dependencies installed"
}

run_django_checks() {
    log_step "Running Django system checks"

    python manage.py check --settings=config.settings.local

    log_info "✓ Django checks passed"
}

test_migrations() {
    log_step "Testing migrations"

    # Create initial migrations
    python manage.py makemigrations --settings=config.settings.local

    # Verify no additional migrations needed
    python manage.py makemigrations --settings=config.settings.local --check --dry-run

    # Apply migrations
    python manage.py migrate --settings=config.settings.local

    log_info "✓ Migrations successful"
}

run_tests() {
    log_step "Running test suite"

    pytest --tb=short

    log_info "✓ Tests passed"
}

build_static_files() {
    log_step "Building static files"

    log_info "  Installing Tailwind dependencies..."
    python manage.py tailwind install --no-input --settings=config.settings.local

    log_info "  Building Tailwind..."
    python manage.py tailwind build --no-input --settings=config.settings.local

    log_info "  Collecting static files..."
    python manage.py collectstatic --noinput --settings=config.settings.local

    if [[ ! -d "assets" ]]; then
        log_error "Static files collection failed"
        exit 1
    fi

    log_info "✓ Static files built successfully"
}

test_docker_build() {
    log_step "Testing Docker build"

    docker build -t "${TEST_PROJECT_NAME}:test" .

    log_info "✓ Docker build successful"
}

test_docker_compose() {
    log_step "Testing docker-compose"

    # Update .env for Docker
    cat > .env << EOF
DEBUG=True
DATABASE_URL=postgres://postgres:password@database:5432/postgres
REDIS_URL=redis://redis:6379
SECRET_KEY=test-secret-key-for-docker
SENTRY_DSN=
EOF

    docker-compose up -d --build

    # Wait for services
    log_info "  Waiting for services to be ready..."
    sleep 15

    # Check web service
    if curl -f http://localhost:8000/admin/ > /dev/null 2>&1; then
        log_info "✓ Web service is responding"
    else
        log_error "Web service not responding"
        docker-compose logs web
        docker-compose down -v
        exit 1
    fi

    # Check for errors in logs
    if docker-compose logs web | grep -i "error" | grep -v "ERROR_LEVEL" > /dev/null; then
        log_warn "Found errors in web service logs"
        docker-compose logs web | grep -i "error" | head -20
    fi

    docker-compose down -v
    log_info "✓ docker-compose test passed"
}

run_type_checking() {
    log_step "Running type checking"

    mypy . --config-file=pyproject.toml || log_warn "mypy found type issues"

    log_info "✓ Type checking completed"
}

run_linting() {
    log_step "Running linting checks"

    ruff check . || log_warn "ruff linter found linting issues"
    ruff format --check . || log_warn "ruff formatter found formatting issues"

    log_info "✓ Linting checks completed"
}

# ============================================================================
# Argument Parsing
# ============================================================================

for arg in "$@"; do
    case $arg in
        --full)
            SKIP_DOCKER=false
            RUN_LINTING=true
            RUN_TYPECHECK=true
            ;;
        --quick)
            SKIP_MIGRATIONS=true
            SKIP_STATIC=true
            SKIP_DOCKER=true
            ;;
        --docker-only)
            DOCKER_ONLY=true
            SKIP_DOCKER=false
            ;;
        --skip-migrations)
            SKIP_MIGRATIONS=true
            ;;
        --skip-static)
            SKIP_STATIC=true
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            ;;
        --help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# ============================================================================
# Main Execution
# ============================================================================

trap cleanup EXIT

main() {
    log_info "Starting template integration tests..."
    log_info "Template: $TEMPLATE_DIR"
    log_info "Test project: $TEST_PROJECT_NAME"
    echo ""

    # Always run core setup
    create_project
    verify_files
    verify_template_substitution
    setup_environment
    install_dependencies

    # Conditional tests based on mode
    if [[ "$DOCKER_ONLY" == true ]]; then
        # Docker-only mode
        test_docker_build
        test_docker_compose
    else
        # Standard tests
        run_django_checks

        [[ "$SKIP_MIGRATIONS" == false ]] && test_migrations

        run_tests

        [[ "$SKIP_STATIC" == false ]] && build_static_files

        # Optional advanced tests
        [[ "$SKIP_DOCKER" == false ]] && test_docker_build
        [[ "$SKIP_DOCKER" == false ]] && test_docker_compose
        [[ "$RUN_TYPECHECK" == true ]] && run_type_checking
        [[ "$RUN_LINTING" == true ]] && run_linting
    fi

    # Success message
    echo ""
    log_info "================================================"
    log_info "  All tests passed successfully! ✓"
    log_info "================================================"
    echo ""

    # Helpful tips
    if [[ "$SKIP_DOCKER" == true ]] && [[ "$DOCKER_ONLY" == false ]]; then
        log_info "Tip: Run with --full for comprehensive testing"
    fi
    if [[ "$SKIP_MIGRATIONS" == true ]] || [[ "$SKIP_STATIC" == true ]]; then
        log_info "Tip: Some tests were skipped. Run without flags for complete validation"
    fi
}

main "$@"
