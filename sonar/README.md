<!--
@guidance:
Describe act toml files located in this filder.
# Guidance File Processing
- "Guided File Processing": https://machanism.org/guided-file-processing/index.html (Selector: `.col-md-12`, textOnly)
- "Guidance": https://machai.machanism.org/ghostwriter/guidance.html (Selector: `#bodyColumn`, textOnly)
# Act
- "Act" and "Using episodes": https://machai.machanism.org/ghostwriter/act.html (Selector: `#bodyColumn`, textOnly)

Use the available function tool to provide information about Ghostwriter acts.

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

`sonar-issues-resolver.toml` defines a multi-episode act that helps resolve open SonarQube issues in Java projects. It is designed to collect issues from SonarQube, group them by rule, apply minimal safe fixes, validate the project, run Sonar analysis again, and prepare a merge request.

#### Purpose

The act supports a full remediation workflow for SonarQube findings:

1. Fetch open issues from SonarQube for the current project or component.
2. Analyze issue metadata such as rule, severity, message, component, line, and text range.
3. Group similar issues by SonarQube rule.
4. Create a dedicated fix branch for each issue group.
5. Apply secure, minimal Java code fixes.
6. Add or update unit tests for modified code.
7. Verify the build with Maven.
8. Run Sonar analysis on the fix branch.
9. Commit, push, and create a GitLab merge request.
10. Continue processing remaining issue groups.

#### Key properties

- `description`: Explains that the act resolves SonarQube issues in Java projects through issue collection, batching, fixing, validation, Sonar reruns, branch push, and merge-request creation.
- `instructions`: Defines the assistant role as a secure Java and DevOps assistant responsible for safe SonarQube remediation, Maven validation, test coverage, secure coding, and OWASP-aligned fixes.
- `inputs`: Contains four episode prompts:
  1. **Collect and Prepare Sonar Issues**: Switches to the source branch, determines the Sonar component key, calls the SonarQube API using `${SONAR_HOST_URL}` and `${SONAR_TOKEN}`, parses issues, groups them by rule, and stores grouped plans in `SONAR_ISSUES`.
  2. **Create a Fix Branch**: Restores the source branch from context, pops the next grouped issue plan, generates a unique `ai-fix-sec-sonar-iss/<DD-MM-YY>-<seqId>` branch name, stores it as `FIX_ISSUES_BRANCH`, and creates the branch.
  3. **Fix One Group of Sonar Issues**: Analyzes the current issue group, applies minimal secure fixes, adds explanatory SonarQube comments above modified code, updates tests, runs `mvn -q verify`, and executes Sonar analysis for the fix branch.
  4. **Create Merge Request**: Commits changes, reads the Sonar report task output, builds merge-request title and description content, pushes the branch with GitLab merge-request options, and loops back to process the next group.
- `prompt`: Set to `<not defined>`.

#### Context variables used

The act uses project context variables to coordinate work across episodes, including:

- `SOURCE_BRANCH`
- `COMPONENT_KEYS`
- `SONAR_ISSUES`
- `CURRENT_SONAR_ISSUES`
- `FIX_ISSUES_BRANCH`
- `UPDATED_SOURCE_FILES`

#### Runtime placeholders and environment values

The act expects several values to be supplied by the runtime environment or project metadata, including:

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

#### Usage

Run the act with:

```text
--act sonar-issues-resolver [optional request text]
```

If optional request text is provided, Ghostwriter formats each episode input with that text. If it is omitted, Ghostwriter uses the processor’s current default prompt.

#### Notes

This act is intended for Java projects that use Maven, SonarQube, Git, and GitLab merge requests. It emphasizes safe remediation, strict build verification, unit-test coverage for changed code, and narrow suppressions only when a real code fix is not feasible.
