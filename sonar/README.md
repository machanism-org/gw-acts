<!--
@guidance:
Describe act toml files located in this filder.
# Guidance File Processing
- "Guided File Processing": https://machanism.org/guided-file-processing/index.html (Selector: `.col-md-12`, textOnly)
- "Guidance": https://machai.machanism.org/ghostwriter/guidance.html (Selector: `#bodyColumn`, textOnly)
# Act
- "Act" and "Using episodes": https://machai.machanism.org/ghostwriter/act.html (Selector: `#bodyColumn`, textOnly)

Use the available function tool to provide information about Ghostwriter acts.
- Show the url to the act: https://raw.githubusercontent.com/machanism-org/gw-acts/refs/heads/main/sonar/<act_file_name>. 
- Carefully analyze the user prompt below and respond accordingly.
- If the user's request provides only the name of the act or the full path to the act file, first retrieve the contents and metadata of the specified act. 
    Analyze the act in detail and generate a comprehensive, user-friendly description that explains its purpose, functionality, and usage. 
    Ensure your explanation is clear and accessible, even for users who may not be familiar with the act or its context.
- If an act exists in both the built-in and user-defined areas, indicate this and note any inheritance or overrides (e.g., “User-defined act overrides built-in act”).
- If the user prompt contains an **act name**, retrieve and summarize the details of that specific act.
  - Include the act’s purpose, key properties (such as `instructions`, `inputs`, `basedOn`, and any `gw.*` options), and any inheritance relationships.
  - Present the information in a clear, user-friendly format.

**How to construct an act command:**
- To run an act, use the following syntax:
  ```
  --act <name> [your request text]
  ```
- If you provide request text after the act name, Ghostwriter uses it; otherwise, it uses the processor’s current default prompt.
- Ghostwriter then formats the act’s `inputs` using your request text:
  ```
  finalPrompt = String.format(inputsTemplate, requestText)
  ```
- The `finalPrompt`, together with the act’s `instructions`, is sent to the AI for processing.
-->

# Sonar Acts

This folder contains Ghostwriter act definitions for SonarQube and code-quality automation workflows.

## Available acts

### `sonar-issues-resolver`

- File: `sonar-issues-resolver.toml`
- URL: https://raw.githubusercontent.com/machanism-org/gw-acts/refs/heads/main/sonar/sonar-issues-resolver.toml
- Command:

```text
--act sonar-issues-resolver [optional request text]
```

`sonar-issues-resolver` is a multi-episode Ghostwriter act for resolving open SonarQube issues in Java projects. It collects issues from SonarQube, groups similar findings, creates a dedicated fix branch for each group, applies minimal safe code changes, validates the project with Maven, reruns Sonar analysis, and prepares a GitLab merge request.

#### Purpose

Use this act when you want Ghostwriter to automate a controlled SonarQube remediation workflow:

1. Fetch open SonarQube issues for the current project or component.
2. Extract issue metadata such as rule, severity, message, component, line, and text range.
3. Group related issues by SonarQube rule so similar fixes can be handled together.
4. Create a unique branch for each grouped issue batch.
5. Apply secure, minimal Java fixes that preserve business behavior.
6. Add or update unit tests for modified code.
7. Run Maven verification until the project builds successfully.
8. Run Sonar analysis on the fix branch.
9. Commit changes, push the branch, and create a GitLab merge request.
10. Continue processing remaining issue groups.

#### Key properties

- `description`: States that the act resolves SonarQube issues in Java projects by collecting open issues, grouping them into batches, applying minimal safe fixes, validating build and tests, rerunning Sonar, and creating a merge request.
- `instructions`: Defines the assistant as a secure Java and DevOps assistant. The act requires safe and minimal fixes, preservation of business behavior, unit-test coverage, Maven validation, narrow suppressions only as a last resort, and adherence to secure coding, SonarQube rule intent, and OWASP practices.
- `inputs`: Contains four episode prompts that guide the workflow from issue collection through merge-request creation.
- `prompt`: `<not defined>`
- `basedOn`: Not defined.
- `gw.*` options: Not defined.

No built-in act metadata was found for `sonar-issues-resolver` through the available act lookup tool. The act is present in this folder as `sonar-issues-resolver.toml`.

#### Episode workflow

##### 1. Collect and Prepare Sonar Issues

This episode prepares the remediation plan.

It instructs Ghostwriter to:

- Switch to `[SOURCE_BRANCH]` and save the active source branch in the `SOURCE_BRANCH` project context variable.
- Determine the Sonar component key from project metadata.
- Build a SonarQube API URL using `${SONAR_HOST_URL}`, `${SONAR_TOKEN}`, `[QUALITIES]`, `[SEVERITY]`, and `[COMPONENT_KEYS]`.
- Retrieve open SonarQube issues.
- Terminate with exit code `500` if the API call fails.
- End the task if no issues are returned.
- Skip fix execution when the current project has modules.
- Parse each issue and extract key fields, including `key`, `rule`, `severity`, `message`, `component`, `line`, and `textRange`.
- Inspect affected files and lines.
- Group issues by rule.
- Store grouped work items in the `SONAR_ISSUES` project context variable.

##### 2. Create a Fix Branch

This episode starts work on one grouped issue plan.

It instructs Ghostwriter to:

- Switch back to the source branch stored in `SOURCE_BRANCH`, or fall back to `${SOURCE_BRANCH}` if no context value exists.
- Pop the next grouped plan from `SONAR_ISSUES` and store it in `CURRENT_SONAR_ISSUES`.
- Terminate execution if there are no remaining issue groups.
- Generate a unique branch name in the format `ai-fix-sec-sonar-iss/<DD-MM-YY>-<seqId>`.
- Save the branch name in `FIX_ISSUES_BRANCH`.
- Create and switch to the fix branch.

##### 3. Fix One Group of Sonar Issues

This episode applies and validates code changes.

It instructs Ghostwriter to:

- Read `FIX_ISSUES_BRANCH` and `CURRENT_SONAR_ISSUES` from project context.
- Inspect affected files and exact code locations.
- Use the relevant SonarQube rule intent to guide each fix.
- Follow secure coding and OWASP recommendations.
- Avoid introducing new SonarQube issues.
- Prefer package-private or protected methods over private static methods when refactoring for testability.
- Add a detailed SonarQube-related comment directly above every modified code block.
- Preserve existing comments.
- Maintain surrounding code style.
- Add or update tests for changed source files recorded in `UPDATED_SOURCE_FILES`.
- Prefer parameterized tests for repeated test logic.
- Run `mvn -q verify` and fix failures until verification succeeds.
- Run branch Sonar analysis with Maven using `[Project Identifier]` and `[FIX_ISSUES_BRANCH]`.
- Add more tests if coverage checks fail.

##### 4. Create Merge Request

This episode publishes the completed fix group.

It instructs Ghostwriter to:

- Create a concise commit message.
- Stage and commit changes automatically.
- Read `CURRENT_SONAR_ISSUES` from project context.
- Read `./target/sonar/report-task.txt` to obtain the Sonar dashboard URL.
- Build a merge-request title from the issue rule.
- Build a merge-request description that includes a summary, Sonar dashboard URL, and key code changes.
- Replace newlines in the merge-request description with `<br>`.
- Push the branch with GitLab merge-request options, including merge-request creation, target branch `main`, title, description, and source-branch removal.
- Move back to episode 2 to process the next issue group.

#### Context variables used

The act coordinates state between episodes with project context variables, including:

- `SOURCE_BRANCH`
- `COMPONENT_KEYS`
- `SONAR_ISSUES`
- `CURRENT_SONAR_ISSUES`
- `FIX_ISSUES_BRANCH`
- `UPDATED_SOURCE_FILES`

#### Runtime placeholders and environment values

The act expects these placeholders, metadata values, or environment-provided values to be available at runtime:

- `${SONAR_HOST_URL}`
- `${SONAR_TOKEN}`
- `${SOURCE_BRANCH}`
- `[SOURCE_BRANCH]`
- `[QUALITIES]`
- `[SEVERITY]`
- `[COMPONENT_KEYS]`
- `[Project Identifier]`
- `[Parent Directory Name]`
- `[Relative Path from Root Directory]`
- `[Modules]`
- `[FIX_ISSUES_BRANCH]`
- `[CURRENT_SONAR_ISSUES]`

#### Usage

Run the act with optional request text:

```text
--act sonar-issues-resolver [optional request text]
```

If request text is provided after the act name, Ghostwriter formats the act inputs with that text. If no request text is provided, Ghostwriter uses the processor's current default prompt.

#### Notes

This act is intended for Java projects that use Maven, SonarQube, Git, and GitLab merge requests. It emphasizes small, reviewable changes; build verification; unit-test coverage for changed code; secure remediation; and suppressions only when a real code fix is not feasible.
