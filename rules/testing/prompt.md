# Testing

- Write tests for new functionality before considering a task complete.
- Follow the Arrange-Act-Assert pattern.
- Use descriptive test names that explain the scenario and expected outcome.
- Prefer unit tests; use integration tests sparingly and only for cross-boundary concerns.
- Mock external dependencies (network, filesystem, time) in unit tests.
- Keep test files next to the code they test, or in a parallel `tests/` directory mirroring `src/`.
- Run the existing test suite before committing to avoid regressions.
