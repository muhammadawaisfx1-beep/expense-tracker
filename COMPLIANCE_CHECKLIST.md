# Compliance Checklist

This checklist ensures all PRs and the repository meet SWE-Bench requirements.

## Repository Requirements

- [x] Minimum 10 files (non-test): **21 files created**
- [x] Minimum 1000 LOC (non-test): **~1050 LOC**
- [x] Ruby language only (≤10% other languages)
- [x] Dockerizable (Dockerfile and docker-compose.yml present)

## PR Requirements

### Before Submitting PR

- [ ] PR links to Issue using one of these formats:
  - `Fixes #123`
  - `Issue is #9`
  - `https://github.com/repo/issues/1000`
  - `ref #1024 and #5`

- [ ] Issue description is clear and specific
- [ ] Issue is closed when PR is merged
- [ ] PR is merged (golden solution)

### Test Requirements

- [ ] At least 3 Unit tests present
- [ ] At least 1 P2P (Pass-to-Pass) test present
- [ ] At least 1 F2P (Fail-to-Pass) test present
- [ ] All tests pass locally
- [ ] Test count matches annotation tool entry

### Code Requirements

- [ ] Minimum 20 lines of code changed (non-test)
- [ ] Code follows Ruby conventions
- [ ] Files changed count matches annotation tool entry
- [ ] Lines of code (test + non-test) match GitHub diff

## Early Rejection Reasons to Avoid

### 1. Variable/Unstable Test Names
- [ ] No test names contain timestamps or variable values
- [ ] Test names are deterministic

### 2. Duplicate Test Names
- [ ] No duplicate test names in P2P/F2P logs

### 3. Failed Tests in Base Log
- [ ] No failed tests in base log are present in P2P

### 4. Failed/Missing Tests in After Log
- [ ] No failed or missing tests in after log are in F2P/P2P

### 5. F2P Tests Successful in Before Log
- [ ] F2P tests are not passing in before log

### 6. P2P Missing in Base, Not Passing in Before
- [ ] All P2P tests missing in base are properly handled

### 7. Empty FAIL_TO_PASS or PASS_TO_PASS
- [ ] Both F2P and P2P arrays have entries in JSON

### 8. Tests Didn't Run in All Stages
- [ ] Tests run in Base, Before, and After stages

### 9. Mismatch Between report.json and post_agent_log
- [ ] Test statuses match between report.json and post_agent_log

### 10. PR Has More Than 15 Test Files
- [ ] Total test files ≤ 15

### 11. PR Has More Than 50 Updated Files
- [ ] Total updated files ≤ 50 (data files like .png, .csv not counted)

## Additional Checks

- [ ] No empty log files (except _post_agent_patch.log)
- [ ] No harness failures
- [ ] Problem statement (issue description) is clear
- [ ] PR and issue descriptions are aligned
- [ ] Commit messages are logical and aligned

## Validation Commands

### Count Lines of Code
Use: https://codetabs.com/count-loc/count-loc-online.html

### Count Files
```bash
find lib config -type f -name "*.rb" | wc -l
```

### Run Tests
```bash
bundle exec rspec
```

### Check Docker Build
```bash
docker-compose build
docker-compose up
```

## PR Submission Checklist

When submitting to labeling tool:

- [ ] Repo link accessible
- [ ] PR link accessible
- [ ] Issue link accessible
- [ ] Programming language: Ruby
- [ ] Number of F2P tests: (count)
- [ ] Number of P2P tests: (count)
- [ ] Task type: Feature or Bug
- [ ] Lines of code - non test: (count)
- [ ] Lines of code - test: (count)
- [ ] Files - test: (count)
- [ ] Files - non test: (count)

