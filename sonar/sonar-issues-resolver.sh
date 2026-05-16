export gw_model="CodeMie:gpt-5.5-2026-04-24"

export GENAI_USERNAME="..."
export GENAI_PASSWORD="..."

export SONAR_HOST_URL="https://..."
export SONAR_TOKEN="squ_..."

mvn org.machanism.machai:gw-maven-plugin:1.1.12-SNAPSHOT:act-per-module \
  -Dgw.act="C:\projects\gw-acts\sonar\sonar-issues-resolver.toml Set SOURCE_BRANCH: 'main'. Set QUALITIES: 'SECURITY'. Set SEVERITY: 'MEDIUM'. Use '-s C:\Users\ViktorTovstyi\.m2\settings.xml' for every maven call. Use MR_TITLE format: '[AI][[QUALITIES]][SONAR] <title>'. Use the '[AI][[QUALITIES]][SONAR]' prefix for every commit message." \

  
  
  