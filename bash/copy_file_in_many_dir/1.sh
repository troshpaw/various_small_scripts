#!/bin/bash

# Task: скопировать fileName.txt во все подкаталоги в пределах текущего рабочего каталога.

# Получаем имени всех вложенных каталогов через ls и сохраняем их в allFolders.txt:
ls -d */ > allFolders.txt

# Передаем список подкаталогов xargs:
cat allFolders.txt | xargs -n 1 cp text.txt