format PE GUI 4.0
entry start

include 'win32a.inc'

ID_CAPTION = 101
SW_SHOW = 5
struct nficon
  cbSize            dd ?
  hWnd              dd ?
  uID               dd ?
  uFlags            dd ?
  uCallbackMessage  dd ?
  hIcon             dd ?
  szTip             rb 128
  dwState           dd ?
  dwStateMask       dd ?
  szInfo            rb 256
  union
  uTimeout          dd ?
  uVersion          dd ?
  ends
  szInfoTitle       rb 64
  dwInfoFlags       dd ?
  guidItem          rd 4
  hBallonIcon       dd ?
ends

section '.text' code readable executable

;proc strncpy dst, src, length
 ;    push ebx esi edi
  ;   lea esi, [src]
    ; lea edi, [dst]
   ;  mov ecx, [length]
    ; stosb
    ; pop edi esi ebx
    ; ret
;endp

start:
        invoke GetModuleHandle, 0
        mov [wc.hInstance], eax


        invoke LoadIcon, 0, IDI_APPLICATION
        mov [wc.hIcon], eax
        invoke LoadCursor, 0, IDC_ARROW
        mov [wc.hCursor], eax
        mov [wc.style], CS_HREDRAW + CS_VREDRAW
        invoke RegisterClass, wc
        invoke CreateWindowEx, 0, class_app, title_main_window, WS_VISIBLE + WS_OVERLAPPEDWINDOW + WS_CLIPCHILDREN + WS_CLIPSIBLINGS, 16, 16, 400, 400, NULL, NULL, [wc.hInstance], NULL
        mov [hwnd_app], eax
        invoke ShowWindow, hwnd_app, SW_SHOW
        invoke UpdateWindow, hwnd_app
msg_loop:
        invoke GetMessage, msg, NULL, 0, 0
        or eax, eax
        jz end_loop
        invoke TranslateMessage, msg
        invoke DispatchMessage, msg
        jmp msg_loop
end_loop:
        invoke ExitProcess, [msg.wParam]

proc WindowProc hwnd, wmsg, wparam, lparam
     push ebx esi edi
     cmp [wmsg], WM_CREATE
     je .wmcreate
     cmp [wmsg], WM_PAINT
     je .wmpaint
     cmp [wmsg], WM_DESTROY
     je .wmdestroy
.defwndproc:
     invoke DefWindowProc, [hwnd], [wmsg], [wparam], [lparam]
     pop edi esi ebx
     ret
.wmcreate:
     invoke CreateWindowEx, 0, class_edit, token, WS_VISIBLE + WS_CHILD + WS_BORDER + ES_PASSWORD, 140, 32 + 24, 128, 24, [hwnd], NULL, [wc.hInstance], NULL
     mov [hwnd_edit_token], eax
     invoke CreateWindowEx, 0, class_edit, token, WS_VISIBLE + WS_CHILD + WS_BORDER, 140, 32 + 24 + 32 + 24, 128, 24, [hwnd], NULL, [wc.hInstance], NULL
     mov [hwnd_edit_nick], eax
     invoke CreateWindowEx, 0, class_edit, token, WS_VISIBLE + WS_CHILD + WS_BORDER, 140, 32 + 24 + 32 + 24 + 32 + 24, 128, 24, [hwnd], NULL, [wc.hInstance], NULL
     mov [hwnd_edit_channel], eax
     invoke CreateWindowEx, 0, class_button, label_button_save, WS_VISIBLE + WS_CHILD + WS_BORDER, 32, 168 + 32, 128, 32, [hwnd], NULL, [wc.hInstance], NULL
     mov [hwnd_button_save], eax
     invoke CreateWindowEx, 0, class_button, label_button_connect, WS_VISIBLE + WS_CHILD + WS_BORDER, 32 + 140, 168 + 32, 128, 32, [hwnd], NULL, [wc.hInstance], NULL
     mov [hwnd_button_connect], eax
     invoke ShowWindow, [hwnd_edit_token], SW_SHOW
     invoke ShowWindow, [hwnd_edit_nick], SW_SHOW
     invoke ShowWindow, [hwnd_edit_channel], SW_SHOW
     invoke ShowWindow, [hwnd_button_save], SW_SHOW
     invoke ShowWindow, [hwnd_button_connect], SW_SHOW
     invoke UpdateWindow, [hwnd_edit_token]
     invoke UpdateWindow, [hwnd_edit_nick]
     invoke UpdateWindow, [hwnd_edit_channel]
     invoke UpdateWindow, [hwnd_button_save]
     invoke UpdateWindow, [hwnd_button_connect]


     mov eax, [size_nid]
     mov [nid.cbSize],eax
     mov eax, [hwnd]
     mov [nid.hWnd], eax
;     mov [nid.uFlags], 10
     mov [nid.uFlags], NIF_INFO

     mov [nid.dwInfoFlags], 0

     invoke strncpy, nid.szTip, str_app_name, [size_str_app_name]
     invoke strncpy, nid.szInfo, str_nid_welcome, [size_str_nid_welcome]
     invoke strncpy, nid.szInfoTitle, str_nid_title, [size_str_nid_title]
     invoke Shell_NotifyIcon, NIM_ADD, nid

     jmp .createfinish
.wmdestroy:
     invoke PostQuitMessage, 0
     xor eax, eax
     jmp .finish
.wmpaint:
     invoke BeginPaint, [hwnd], ps
     mov [hdc], eax
     invoke TextOut, [hdc], 32, 32 + 24 + 4, label_token, [size_label_token]
     invoke TextOut, [hdc], 32, 32 + 24 +32 + 24 + 4, label_nick, [size_label_nick]
     invoke TextOut, [hdc], 32, 32 + 24 + 32 + 24 + 32 + 24 + 4, label_channel, [size_label_channel]
     invoke EndPaint, [hwnd], ps
     jmp .finish
.createfinish:
     mov eax, 0
     pop edi esi ebx
     ret
.finish:
     xor eax, eax
     pop edi esi ebx
     ret
endp

section '.bss' readable writable

caption rb 0xff


section '.idata' import data readable writable

library kernel, 'KERNEL32.DLL', \
        user, 'USER32.DLL', \
        gdi, 'GDI32.DLL', \
        shell, 'SHELL32.DLL', \
        msvcrt, 'MSVCRT.DLL'

import  kernel,\
        GetModuleHandle, 'GetModuleHandleA', \
        ExitProcess, 'ExitProcess'

import  user, \
        RegisterClass, 'RegisterClassA', \
        CreateWindowEx, 'CreateWindowExA', \
        DefWindowProc, 'DefWindowProcA', \
        ShowWindow, 'ShowWindow', \
        UpdateWindow, 'UpdateWindow', \
        GetMessage, 'GetMessageA', \
        TranslateMessage, 'TranslateMessage', \
        DispatchMessage, 'DispatchMessageA', \
        LoadCursor, 'LoadCursorA', \
        LoadIcon, 'LoadIconA', \
        GetClientRect, 'GetClientRect', \
        GetDC, 'GetDC', \
        ReleaseDC, 'ReleaseDC', \
        PostQuitMessage, 'PostQuitMessage', \
        BeginPaint, 'BeginPaint', \
        EndPaint, 'EndPaint'

import  msvcrt, \
        strncpy, 'strncpy'

import  shell, \
        Shell_NotifyIcon, 'Shell_NotifyIconA'

import  gdi, \
        TextOut, 'TextOutA'

section '.data' data readable writable

title_main_window db 'twitch notificator', 0
class_app db 'twitchbot', 0
class_edit db 'edit', 0
class_button db 'button', 0
token db '', 0
label_token db 'OAUTH_TOKEN', 0
size_label_token dd $ - label_token
label_nick db 'NICK', 0
size_label_nick dd $ - label_nick
label_channel db 'CHANNEL', 0
size_label_channel dd $ - label_channel
label_button_save db 'Save', 0
label_button_connect db 'Connect', 0
str_app_name db 'twitch-notificator', 0
size_str_app_name dd $ - str_app_name
str_nid_welcome db 'Welcome to bot notificator', 0
size_str_nid_welcome dd $ - str_nid_welcome
str_nid_title db 'twitch-notificator', 0
size_str_nid_title dd $ - str_nid_title
wc WNDCLASS 0, WindowProc, 0, 0, NULL, NULL, NULL, NULL, NULL, class_app
size_wc dd $ - wc
hdc dd ?
ps PAINTSTRUCT
hwnd_app dd ?
hwnd_edit_token dd ?
hwnd_edit_nick dd ?
hwnd_edit_channel dd ?
hwnd_button_save dd ?
hwnd_button_connect dd ?
nid nficon
size_nid dd $ - nid
msg MSG