{ pkgs, curl, git, gnupg, lib, writeScript, python3, common-updater-scripts, coreutils, gnugrep, gnused }:
{ packageName, attrPath ? packageName, versionPolicy ? "odd-unstable" }:

let
  python = python3.withPackages (p: [ p.requests ]);
  package = pkgs.lib.attrByPath (pkgs.lib.splitString "." attrPath) null pkgs;
in writeScript "update-${packageName}" ''
  set -o errexit
  function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
  PATH=${lib.makeBinPath [ common-updater-scripts git gnupg curl coreutils gnugrep gnused python ]}
  latest_tag=$(python "${./find-latest-version.py}" "${packageName}" "${versionPolicy}" "unstable")
  current_version=${package.version or (builtins.parseDrvName package.name).version}
  if version_gt "$latest_tag" "$current_version"; then
    update-source-version "${attrPath}" "$latest_tag"
    git add -u
    git commit -m "${attrPath}: $current_version → $latest_tag"

    echo "${packageName}: $current_version → $latest_tag" >> gnome-updates.log
    echo "${packageName}: $current_version → $latest_tag" >> gnome-news/${packageName}
    echo "===========================================" >> gnome-news/${packageName}
    curl -L https://github.com/GNOME/${packageName}/raw/master/NEWS >> gnome-news/${packageName}
  fi
''
