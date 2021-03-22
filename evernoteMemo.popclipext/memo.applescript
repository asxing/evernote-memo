-- frequently used notebook
property _notebook: "01-待整理"

-- show user interact dialog for the first time
if _notebook is "" then

    -- ask user to choose which notebook to save
    -- create new notebook or use created notebook
    try
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
    end try
end if

-- if _notebook is still empty then exit
if _notebook is "" then
    return
end if

-- get related info
set theDate to date string of (current date)
set theTime to time string of (current date)
set noteName to "备忘 - " & theDate
set appName to "{popclip app name}"

-- create new note or append data to existed note
tell application "Evernote"
    set queryResults to (find notes noteName)
    if count of queryResults is not 0 then
        set theNote to item 1 of queryResults
        set theNotebook to notebook of theNote
        if name of theNotebook equals _notebook then
            set contentInNote to "<br /><pre>" & "{popclip text}" & "</pre><div><strong><<< " & appName & " - " & theTime & "</strong></div>"
            append theNote html contentInNote
            return
        end if
    end if

    set contentInNote to "<pre>" & "{popclip text}" & "</pre><div><strong><<< " & appName & " - " & theTime & "</strong></div>"
    create note title noteName notebook _notebook with html contentInNote

    display dialog "备忘成功添加至笔记本[" & _notebook & "]!"
end tell