FROM appveyor/build-image:minimal-windowsservercore-ltsc2019
RUN choco install -y nodejs-lts
CMD [ 'node -v']