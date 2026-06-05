# Language and Runtime Audit Checklist

Reference when inventorying available review tools.
Run any command that is available and safe in the current environment.

## Rust

```sh
cargo build                   # compile errors and warnings
cargo test                    # unit and integration tests
cargo clippy -- -D warnings   # lints
cargo audit                   # known vulnerability advisories
cargo outdated                # outdated dependencies
```

## JavaScript / TypeScript

```sh
npm audit                     # known vulnerability advisories (or yarn audit / pnpm audit)
tsc --noEmit                  # type errors (TypeScript only)
eslint .                      # lints
jest / vitest / mocha         # tests
```

## Python

```sh
pip-audit                     # known vulnerability advisories
bandit -r .                   # security lints
mypy .                        # type errors
pylint / ruff .               # lints
pytest                        # tests
```

## Go

```sh
go build ./...                # compile errors
go test ./...                 # tests
go vet ./...                  # static analysis
govulncheck ./...             # known vulnerability advisories
staticcheck ./...             # lints
```

## Java

```sh
mvn verify                    # build + tests (Maven)
gradle check                  # build + tests + lints (Gradle)
mvn dependency:analyze        # unused and missing dependencies
```

## C# / .NET

```sh
dotnet build                  # compile errors and warnings
dotnet test                   # tests
dotnet list package --vulnerable   # known vulnerable packages
```

## C / C++

```sh
cmake --build .               # compile
ctest                         # tests
clang-tidy                    # static analysis and lints
cppcheck .                    # additional static analysis
valgrind                      # memory errors (Linux)
```

## Ruby

```sh
bundle audit                  # known vulnerability advisories
rubocop                       # lints
rspec / minitest              # tests
```

## PHP

```sh
composer audit                # known vulnerability advisories
phpstan analyse               # static analysis
phpcs                         # code style
phpunit                       # tests
```
