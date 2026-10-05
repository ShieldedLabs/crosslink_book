@echo off
rem Builds the book into .\book using the mdbook-mermaid checked in under tools\.
setlocal
set PATH=%~dp0tools;%PATH%
cd /d %~dp0
mdbook-mermaid install . || exit /b 1
mdbook build %*
