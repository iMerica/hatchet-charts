#!/usr/bin/env bash
set -euo pipefail

CHART_DIR="charts/hatchet-ha"
CHART_VERSION="0.9.2"
TGZ_FILE="hatchet-ha-${CHART_VERSION}.tgz"

echo "🧹 Cleaning vendored deps..."
rm -rf "${CHART_DIR}/charts"/*

echo "📦 Updating dependencies..."
helm dependency update "${CHART_DIR}"

echo "📦 Packaging hatchet-api into hatchet-ha/charts..."
helm package charts/hatchet-api -d "${CHART_DIR}/charts"

echo "🛠 Packaging parent chart..."
rm -f "${TGZ_FILE}"
helm package "${CHART_DIR}" -d .

echo "🔍 Verifying contents..."
tar tzf "${TGZ_FILE}" | egrep 'pgbouncer|rabbitmq|postgresql|hatchet-api' || true

echo "🗂 Updating repo index..."
helm repo index . --merge index.yaml

echo "📤 Committing & pushing..."
git add "${TGZ_FILE}" index.yaml "${CHART_DIR}/charts"/*
git commit -m "Rebuild hatchet-ha ${CHART_VERSION} with latest changes"
git push iMerica HEAD:master

echo "✅ Done. ${TGZ_FILE} is up-to-date with repo changes."
