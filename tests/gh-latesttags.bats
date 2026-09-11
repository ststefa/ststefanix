#!/usr/bin/env bats

setup() {
  SCRIPT="${BATS_TEST_DIRNAME}/../home/files/common/bin/gh-latesttags"
  FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${FAKE_BIN}"
  PATH="${FAKE_BIN}:${PATH}"
}

write_fake_gh() {
  printf '%s\n' "$@" > "${FAKE_BIN}/gh"
  chmod +x "${FAKE_BIN}/gh"
}

@test "prints current usage without required arguments" {
  run "${SCRIPT}"

  [ "${status}" -eq 1 ]
  [[ "${output}" == *"Usage: gh-latesttags <org> <package> [limit]"* ]]
  [[ "${output}" == *"Defaults to 5."* ]]
  [[ "${output}" == *"https://github.com/orgs/<org>/packages?ecosystem=container"* ]]
}

@test "filters internal tags and keeps release tags" {
  write_fake_gh \
    '#!/usr/bin/env bash' \
    'cat <<JSON' \
    '[' \
    '  {' \
    '    "created_at": "2026-09-11T04:32:16Z",' \
    '    "name": "sha256:newest",' \
    '    "metadata": {"container": {"tags": ["1.9-dev", "release-1.9.x", "buildcache-layer", "sha256-test", "caad76b", "5ea54ee"]}}' \
    '  }' \
    ']' \
    'JSON'

  run "${SCRIPT}" artifact-keeper artifact-keeper-openscap

  [ "${status}" -eq 0 ]
  [[ "$(jq -r '.[0].tags | join(" ")' <<<"${output}")" == "1.9-dev release-1.9.x" ]]
}

@test "limit selects newest entries and prints them oldest to newest" {
  write_fake_gh \
    '#!/usr/bin/env bash' \
    'case " $* " in' \
    '  *" page=1 "*)' \
    '    cat <<JSON' \
    '[' \
    '  {"created_at": "2026-09-11T04:32:16Z", "name": "sha256:newest", "metadata": {"container": {"tags": ["newest"]}}},' \
    '  {"created_at": "2026-09-10T16:42:35Z", "name": "sha256:middle", "metadata": {"container": {"tags": ["middle"]}}},' \
    '  {"created_at": "2026-09-09T00:02:11Z", "name": "sha256:oldest", "metadata": {"container": {"tags": ["oldest"]}}}' \
    ']' \
    'JSON' \
    '    ;;' \
    '  *)' \
    '    printf "%s\n" "[]"' \
    '    ;;' \
    'esac'

  run "${SCRIPT}" artifact-keeper artifact-keeper-openscap 2

  [ "${status}" -eq 0 ]
  [[ "$(jq -r '.[].tags[0]' <<<"${output}")" == $'middle\nnewest' ]]
}

@test "limit 1 returns newest entry" {
  write_fake_gh \
    '#!/usr/bin/env bash' \
    'cat <<JSON' \
    '[' \
    '  {"created_at": "2026-09-11T04:32:16Z", "name": "sha256:newest", "metadata": {"container": {"tags": ["newest"]}}},' \
    '  {"created_at": "2026-09-10T16:42:35Z", "name": "sha256:middle", "metadata": {"container": {"tags": ["middle"]}}}' \
    ']' \
    'JSON'

  run "${SCRIPT}" artifact-keeper artifact-keeper-openscap 1

  [ "${status}" -eq 0 ]
  [[ "$(jq -r '.[0].tags[0]' <<<"${output}")" == "newest" ]]
}

@test "stops immediately when gh api fails" {
  write_fake_gh \
    '#!/usr/bin/env bash' \
    'echo "gh: Not Found (HTTP 404)" >&2' \
    'exit 1'

  run "${SCRIPT}" foo bar

  [ "${status}" -eq 1 ]
  [[ "${output}" == "gh: Not Found (HTTP 404)" ]]
}
