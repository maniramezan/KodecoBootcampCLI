# Kodeco Bootcamp CLI

This project is a CLI tool created as part of the Kodeco Bootcamp. It is a simple tool that shows how to create a CLI tool using Swift. This automates the workflow of creating a new branch for weekly HW submissions:

- Create a branch name: 'weekXX'
- Create a folder named 'weekXX'
- For some, copy sample project into 'weekXX' folder
- git add
- git commit
- git push the new branch

This also could be done in shell script by adding following code in .bashrc or .zshrc file:

```bash
# Kodeco create hw project
kodeco-create-hw-project() {
  # Verify that the user has provided an argument for branch name
  if [ -z "$1" ]
    then
      echo "No argument supplied"
      return 1
  fi
  BRANCH_NAME="$1"
  git checkout -b $BRANCH_NAME
  mkdir $BRANCH_NAME
  if [ "$2" ]
    then
      SAMPLE_APP_PATH="$2"
      cp -rf $SAMPLE_APP_PATH ./$BRANCH_NAME/
  fi
  git add .
  git commit -m "Add $BRANCH_NAME branch"
  git push -u origin $BRANCH_NAME
}
```