# PowerShell Registry Modules Test

This repository contains PowerShell modules related to managing and analyzing baseball data. The included Pester tests ensure the functionality and reliability of these modules.

## Pester Tests

The repository includes Pester tests for various PowerShell modules related to baseball data. Each test ensures that the modules function as expected and meet the required standards.

### Test Execution Workflow

The Pester tests are executed using GitHub Actions on each push to the repository. The workflow runs on an Ubuntu environment and performs the following steps:

1. **Check out repository code:**
   - Uses GitHub Actions to check out the latest code from the repository.

2. **Perform a Pester test from the command-line:**
   - Checks if a results file exists using the `Test-Path` command.

3. **Perform Pester tests from individual test files:**
   - Invokes Pester tests from specific test files (e.g., `Unit.Tests.ps1`, `Get-Dugout.Tests.ps1`, etc.).
   - Outputs the results in NUnit XML format.

4. **Run Pester tests for each module:**
   - Invokes Pester tests for each PowerShell module.
   - Outputs individual test results in NUnit XML format.

5. **Archive test results:**
   - Archives the NUnit XML files for each module as artifacts for further analysis.

### Test Results

You can find the test results in the `test-results` directory. Each module's test results are stored in separate NUnit XML files.
