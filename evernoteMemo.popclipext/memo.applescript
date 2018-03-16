-- * program *

-- get notebook defined by user
set _notebook to getDefinedNotebook()
-- get user's notebook list
set _notebookList to getNotebookList()
-- create note name
set _noteName to createNoteName()

if _notebook is not "" then
    if isNotebookExisted(_notebook, _notebookList) then
        appendNoteToNotebook(_noteName, _notebook)
    else
        display dialog "未找到用户定义的笔记本，请检查插件设置。"
    end if
else
    -- ask user to choose which notebook to save
    -- create new notebook or use created notebook
    try
        set _dialog to (display dialog "请选择备忘存放的笔记本：" buttons {"新建笔记本", "已创建的笔记本"} default button "已创建的笔记本" with title "选择笔记本")
        if button returned of _dialog = "已创建的笔记本" then
            -- ask user to choose one of the created notebook
            set _selections to (choose from list _notebookList with title "选择已创建的笔记本" with prompt "已创建的笔记本：")
            if _selections is not false then
                set _notebook to item 1 of _selections
            end if
        else
            -- create new notebook with assigned name
            set _notebook to createNewNotebook()
        end if
    end try

    if _notebook is not "" then
        appendNoteToNotebook(_noteName, _notebook)
    end if
end if

-- * functions *

-- get app name where text get selected
on getAppName()
    return "{popclip app name}"
end getAppName

-- get name of the notebook defined by user
on getDefinedNotebook()
    set _notebook to "{popclip option notebook}"
    -- user didn't define where to save new note
    if _notebook contains "popclip option"
        set _notebook to ""
    end if

    return _notebook
end getDefinedNotebookName

-- get selected text as note
on getNoteContent()
    set _noteContent to "{popclip text}"
    -- user selected empty text
    if _noteContent contains "popclip text"
        set _noteContent to ""
    end if

    return _noteContent
end getNoteContent

-- create new notebook
on createNewNotebook()
    -- ask user to input new notebook name
    -- create new notebook with assigned name
    set _dialog to (display dialog "命名为：" with title "创建新笔记本" default answer "")
    if button returned of _dialog is not false then
        set _notebook to text returned of _dialog
        if _notebook is not "" then
            tell application "Evernote"
                create notebook _notebook
            end tell
        end if
        return _notebook
    end if
end createNewNotebook

-- get notebook list
on getNotebookList()
    tell application "Evernote"
        -- get all created notebook to Notebook List
        set notebookList to {}
        set allNotebooks to every notebook
        repeat with currentNoteBook in allNotebooks
            set notebookList to notebookList & name of currentNoteBook
        end repeat

        return notebookList
    end tell
end getNotebookList

-- check if notebook existed in list
on isNotebookExisted(_notebook, _notebookList)
    return _notebookList contains _notebook
end matchNotebookInList

-- create note name
on createNoteName()
    -- get related info
    set _date to date string of (current date)

    -- create note name
    set _noteName to "备忘 - " & _date

    return _noteName
end createNoteName

-- create note in format
on createNoteInFormat(_isFirstNote, _note)
    -- get related info
    set _time to time string of (current date)
    set _appName to getAppName()

    -- concat note
    if _isFirstNote then
        set _noteInFormat to "<div>" & _note & "</div><div><strong><<< " & _appName & " - " & _time & "</strong></div>"
    else
        set _noteInFormat to "<br /><div>" & _note & "</div><div><strong><<< " & _appName & " - " & _time & "</strong></div>"
    end if

    return _noteInFormat
end createNoteInFormat

-- create new note or append data to existed note
on appendNoteToNotebook(_noteName, _notebook)
    activate application "Evernote"
    tell application "Evernote"
        set queryResults to (find notes _noteName)
        if count of queryResults is not 0 then
            set _existedNote to item 1 of queryResults
            set _existedNotebook to notebook of _existedNote
            if name of _existedNotebook equals _notebook then
                set _note to my createNoteInFormat(false, my getNoteContent())
                append _existedNote html _note
                display dialog "备忘成功添加至现有笔记！"
                return
            end if
        end if

        set _note to my createNoteInFormat(true, my getNoteContent())
        create note title _noteName notebook _notebook with html _note

        display dialog "备忘成功添加至笔记本[" & _notebook & "]!"
    end tell
end appendNoteToNotebook