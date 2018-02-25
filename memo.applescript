-- frequently used notebook
property _notebook: ""

-- show user interact dialog for the first time
if _notebook is "" then

    -- ask user to choose which notebook to save
    -- create new notebook or use created notebook
    try
        set theDialog to (display dialog "请选择备忘存放的笔记本：" buttons {"新建笔记本", "已创建的笔记本"} default button "已创建的笔记本" with title "选择笔记本")
        if button returned of theDialog = "已创建的笔记本" then
            tell application "Evernote"
                -- get all created notebook to Notebook List
                set notebookList to {}
                set allNotebooks to every notebook
                repeat with currentNoteBook in allNotebooks
                    set notebookList to notebookList & name of currentNoteBook
                end repeat

                -- ask user to choose one of the created notebook
                set selections to (choose from list notebookList with title "选择已创建的笔记本" with prompt "已创建的笔记本：")
                if selections is not false then
                    set _notebook to item 1 of selections
                end if

            end tell
        else
            -- ask user to input new notebook name
            -- create new notebook with assigned name
            set theDialog to (display dialog "命名为：" with title "创建新笔记本" default answer "")
            if button returned of theDialog is not false then
                set _notebook to text returned of theDialog
                if _notebook is "" then
                    return
                end if

                tell application "Evernote"
                    create notebook _notebook
                end tell
            end if
        end if

    end try

end if

-- get current date string
set theDate to date string of (current date)
set noteName to "备忘 - " & theDate

-- create new note or append data to existed note
tell application "Evernote"
    set queryResults to (find notes noteName)
    if count of queryResults = 0 then
        set contentInNote to "<div>" & "{popclip text}" & "</div>"
        create note title noteName notebook _notebook with html contentInNote
    else
        set theNote to item 1 of queryResults
        set contentInNote to "<br /><div>" & "{popclip text}" & "</div>"
        append theNote html contentInNote
    end if

    display dialog "备忘添加成功！"
end tell