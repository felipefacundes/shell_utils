git_help() {
    cat <<'EOF' | less -Ri
# GIT Complete Documentation
googel>>Install Git
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git // Type "git" to check it work or not?
All about git: https://gist.github.com/subrotoice/b27f7d20617bb3da04827a223faf6450
FAQ: https://stackoverflow.com/questions/1443210/updating-a-local-repository-with-changes-from-a-github-repository

# Basic Windows command like cd
cd\  = back to root directory c drive does not metter where its current postion 
cd .. = One step back
cd /d D: = C Drive to D drive
dir or ls(LS)  = List all file and folder of current directory. "ls" is more clear to read
mkdir mynewfolder = Create New Folder
cd "folderName" = To enter Folder for doing some task
cls = Clear Screen

# Upload A full new project (Make sure no file there even readme.md to avoid error)--Working==========
git config --global user.name "subrotoice"
git config --global user.email "subroto.iu@gmail.com"

git init    // Basically 3 steps, 1. add, 2. Commit, 3. Push
git add .   // Add to local repositories
git commit -m "first commit"  // Commit to local repositories
git remote add origin https://github.com/subrotoice/ccn.git  // ("origin user-defined", origin=url.git, variable e value assign korar moto)
git push -u origin master  // push,  origin user define name like variable contain url. (master default brunch name, you can create brunch like, https://prnt.sc/26pq9x2

# master(default),  If you want to create other brunch not master(default), here brunch name is "main", user-defined name
git branch -M main // Create new branch main
git remote add origin https://github.com/subrotoice/33sfdf.git  // origin(any name) is variable name contain url, age url assing thakle ei line dorkar nai
git push -u origin main

git branch // Show current branch
git checkout master // Switched to branch 'master'

# Work on existing Project----------------
First you have to download project otherwise it will not work
git clone https://github.com/Tilotiti/jQuery-LightBox-Responsive.git   // Pull
cd folder_name // Need to change to inside folder
git add . For all new file and folder (git add file_names.exten  it is for single file)
git status  // to check the status of git files [optional]
git commit -m "committed message" For asingle file(git commit -m "committed message" file_names.exten)
git push -u origin master  
git pull origin master (or main)// Change in github, it take effect in local reprository. 'Synchronization'

# Basics for updating repository
$ git add . (for all files) // Or git add file
$ git commit -m 'Update ...'
$ git push // Or git push -u origin main // Or git push origin main
Or ...
$ git add . (for all files) // Or git add file
$ git commit -m 'Update ...'
$ git pull origin main 
$ git pull --rebase origin main # If necessary
$ git push // Or git push -u origin main // Or git push origin main

# Clone a Specic Brunch, in stade of main brunch master
git clone --branch <branchname> <remote-repo-url>
git clone -b <branchname> <remote-repo-url>
git clone -b main9 https://github.com/subrotoice/test9.git  // Working, Here brunch name main9
git push -u origin main9 // Push to main9, Error: if use master as brunch name
git pull origin master // Change in github, it take effect in local reprository 

# VS Code--- Command dorkar nai, Sob visually kora jai
https://www.youtube.com/watch?v=2oihkInZ880  (Hindi)
1st time step: -----(Local: 1-3, Remote: a-d)--------------
1. Initialize Repository // https://prnt.sc/V7oDXeeOi9CO
2. Commit  // Visually Commit
3. COnfig Git(If ask)

a. Add Remote  // Visually Commit https://prnt.sc/-IWSFNeadc1H
b. Push  // Commit and push option ase vscode
c. Github Auth
d. Push Again (If required)

2nd Time (Old Project):
1. Pule (clone) // https://prnt.sc/K2us0_eYZFuq
2. Commit

a. Push
# https://prnt.sc/5ii9wCPT9Qut // Change in github, it take effect in local reprository
EOF
}