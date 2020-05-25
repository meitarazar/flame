#!/bin/bash -xe

if [[ $(flutter format -n .) ]]; then
    echo "flutter format issue"
    exit 1
fi

flutter pub get
result=$(dartanalyzer lib/)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dartanalyzer issue: lib"
  exit 1
fi

cd example/
flutter pub get
result=$(dartanalyzer .)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dartanalyzer issue: example"
  exit 1
fi
cd ..

changed_examples=$(git diff --name-only develop... doc/examples \
  | xargs -I {} dirname {} | sed 's/\/lib$//' | uniq \
  | xargs -I {} find {} -name pubspec.yaml | xargs -I {} dirname {})
for d in $changed_examples; do
  cd $d
  flutter pub get
  result=$(dartanalyzer .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "dartanalyzer issue: $d"
    exit 1
  fi
  cd -
done

echo "success"
exit 0
