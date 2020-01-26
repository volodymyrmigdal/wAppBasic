FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.4.1
ENV NODE_SHA256 630bc34155e7fdb65c02ed44a37cd27dcf3f76a061c220e7af8baacdb0c2bb9c

RUN powershell -Command wget -Uri https://nodejs.org/dist/v12.14.1/node-v12.14.1-x64.msi -OutFile node.msi -UseBasicParsing ; \
    if ((Get-FileHash node.msi -Algorithm sha256).Hash -ne $env:NODE_SHA256) {exit 1} ; \
    Start-Process -FilePath msiexec -ArgumentList /q, /i, node.msi -Wait ; \
    Remove-Item -Path node.msi

RUN powershell -Command Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-64-bit.zip' -OutFile MinGit.zip

RUN powershell -Command Expand-Archive c:\MinGit.zip -DestinationPath c:\MinGit; \
$env:PATH = $env:PATH + ';C:\MinGit\cmd\;C:\MinGit\cmd'; \
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $env:PATH

RUN git --version

RUN git clone https://github.com/volodymyrmigdal/wExternalFundamentals.git
WORKDIR "/wExternalFundamentals"
RUN npm -v
RUN npm i
RUN npm test