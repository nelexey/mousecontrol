#Requires AutoHotkey v2.0
#SingleInstance Force

; Глобальные переменные
global isActive := false          ; Статус скрипта (вкл/выкл)
global isMouseDragging := false   ; Статус перетаскивания
global mouseSpeed := 12           ; Базовая скорость движения мыши

; Состояния клавиш направления
global keyUp := false
global keyDown := false
global keyLeft := false
global keyRight := false

; Индикатор статуса
global statusIndicator := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
statusIndicator.BackColor := "Black"
statusIndicator.SetFont("s10", "Arial")
global statusText := statusIndicator.Add("Text", "cGreen w140 h20", "Mouse Control: ON")
statusIndicator.Hide()  ; Скрываем индикатор по умолчанию

; F9: Включение/выключение скрипта
F9:: ToggleMouseControl()

; Функция включения/выключения управления мышью
ToggleMouseControl() {
    global isActive, isMouseDragging
    
    isActive := !isActive
    
    if (isActive) {
        ; Показываем индикатор
        statusIndicator.Show("x10 y10 NoActivate")
    } else {
        ; Скрываем индикатор
        statusIndicator.Hide()
        
        ; Если было активно перетаскивание, отключаем его
        if (isMouseDragging) {
            Click "Up"
            isMouseDragging := false
        }
        
        ; Сбрасываем состояния клавиш
        keyUp := false
        keyDown := false
        keyLeft := false
        keyRight := false
        
        ; Останавливаем таймер движения
        SetTimer MoveMouse, 0
    }
}

; Обработка клавиш
#HotIf isActive
    Up::HandleKeyUp()
    Down::HandleKeyDown()
    Left::HandleKeyLeft()
    Right::HandleKeyRight()
    
    Enter::Click("Left")
    ^Enter::Click("Right")
    
    p::ToggleDrag()
#HotIf

; Функции обработки нажатия клавиш
HandleKeyUp() {
    global keyUp
    keyUp := true
    CheckMovement()
}

HandleKeyDown() {
    global keyDown
    keyDown := true
    CheckMovement()
}

HandleKeyLeft() {
    global keyLeft
    keyLeft := true
    CheckMovement()
}

HandleKeyRight() {
    global keyRight
    keyRight := true
    CheckMovement()
}

; Обработка отпускания клавиш
#HotIf isActive
    Up Up::HandleKeyUpRelease()
    Down Up::HandleKeyDownRelease()
    Left Up::HandleKeyLeftRelease()
    Right Up::HandleKeyRightRelease()
#HotIf

; Функции обработки отпускания клавиш
HandleKeyUpRelease() {
    global keyUp
    keyUp := false
    CheckMovement()
}

HandleKeyDownRelease() {
    global keyDown
    keyDown := false
    CheckMovement()
}

HandleKeyLeftRelease() {
    global keyLeft
    keyLeft := false
    CheckMovement()
}

HandleKeyRightRelease() {
    global keyRight
    keyRight := false
    CheckMovement()
}

; Проверка текущего движения
CheckMovement() {
    global keyUp, keyDown, keyLeft, keyRight
    
    ; Если хоть одно направление активно, запускаем таймер
    if (keyUp || keyDown || keyLeft || keyRight) {
        SetTimer MoveMouse, 1
    } else {
        SetTimer MoveMouse, 0
    }
}

; Функция для перемещения мыши
MoveMouse() {
    global keyUp, keyDown, keyLeft, keyRight, mouseSpeed
    
    ; Расчёт вектора движения
    dx := 0
    dy := 0
    
    if (keyLeft)
        dx -= mouseSpeed
    if (keyRight)
        dx += mouseSpeed
    if (keyUp)
        dy -= mouseSpeed
    if (keyDown)
        dy += mouseSpeed
    
    ; Корректировка для диагонального движения
    if (dx != 0 && dy != 0) {
        factor := 1 / Sqrt(2)
        dx *= factor
        dy *= factor
    }
    
    ; Перемещение мыши
    MouseMove dx, dy, 0, "R"
}

; Функция для переключения режима перетаскивания
ToggleDrag() {
    global isMouseDragging
    
    isMouseDragging := !isMouseDragging
    
    if (isMouseDragging)
        Click "Down"
    else
        Click "Up"
}

; Добавляем системную иконку в трей
TraySetIcon "Shell32.dll", 44  ; Иконка курсора
A_TrayMenu.Add("О скрипте", ShowAbout)
A_TrayMenu.Default := "О скрипте"

; Информационное окно о скрипте
ShowAbout(*) {
    MsgBox "Скрипт управления мышью с клавиатуры`n`n" .
           "F9: Включить/выключить управление`n" .
           "Стрелки: Перемещение курсора`n" .
           "Enter: Левый клик`n" .
           "Ctrl+Enter: Правый клик`n" .
           "P: Зажать/отпустить левую кнопку мыши"
}