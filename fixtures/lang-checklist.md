# Language and Runtime Audit Checklist

Reference when inventorying available review tools.
Run any command that is available and safe in the current environment.
For coverage, first inspect project scripts, dependency manifests, coverage config, and CI config. Run coverage commands only when the project already has the needed tool or configuration; do not install coverage tools unless the user approves.

## Rust

```sh
cargo build                   # compile errors and warnings
cargo test                    # unit and integration tests
cargo clippy -- -D warnings   # lints
cargo audit                   # known vulnerability advisories
cargo outdated                # outdated dependencies
cargo llvm-cov                # coverage, if cargo-llvm-cov is installed/configured
cargo tarpaulin               # coverage, if cargo-tarpaulin is installed/configured
```

## JavaScript / TypeScript

```sh
npm audit                     # known vulnerability advisories (or yarn audit / pnpm audit)
tsc --noEmit                  # type errors (TypeScript only)
eslint .                      # lints
jest / vitest / mocha         # tests
jest --coverage               # coverage, if Jest is configured
vitest run --coverage         # coverage, if Vitest coverage is configured
npm test -- --coverage        # coverage, if the test script supports it
```

## Python

```sh
pip-audit                     # known vulnerability advisories
bandit -r .                   # security lints
mypy .                        # type errors
pylint / ruff .               # lints
pytest                        # tests
pytest --cov                  # coverage, if pytest-cov is configured
coverage run -m pytest        # coverage, if coverage.py is configured
coverage report               # coverage summary, after coverage data exists
```

## Go

```sh
go build ./...                # compile errors
go test ./...                 # tests
go test ./... -coverprofile=coverage.out   # coverage profile
go vet ./...                  # static analysis
govulncheck ./...             # known vulnerability advisories
staticcheck ./...             # lints
```

## Java

```sh
mvn verify                    # build + tests (Maven)
gradle check                  # build + tests + lints (Gradle)
mvn dependency:analyze        # unused and missing dependencies
mvn test jacoco:report        # coverage, if JaCoCo is configured
gradle test jacocoTestReport  # coverage, if JaCoCo is configured
```

## C# / .NET

```sh
dotnet build                  # compile errors and warnings
dotnet test                   # tests
dotnet list package --vulnerable   # known vulnerable packages
dotnet test --collect:"XPlat Code Coverage"   # coverage, if collector is configured
```

## C / C++

```sh
cmake --build .               # compile
ctest                         # tests
clang-tidy                    # static analysis and lints
cppcheck .                    # additional static analysis
valgrind                      # memory errors (Linux)
gcov / lcov                   # coverage, only with existing instrumented build config
```

## Ruby

```sh
bundle audit                  # known vulnerability advisories
rubocop                       # lints
rspec / minitest              # tests
simplecov                     # coverage, if configured in the test suite
```

## PHP

```sh
composer audit                # known vulnerability advisories
phpstan analyse               # static analysis
phpcs                         # code style
phpunit                       # tests
phpunit --coverage-text       # coverage, if Xdebug/PCOV and PHPUnit coverage are configured
```
