# Lagecorp Template Repository (LTR)

This repository provides a generic baseline for new Git repositories.

## Requirements

- Internet access
- Git SCM

## Usage Instructions

Replace `NewRepo` with the desired name for the new repository and proceed as follows.

- In any shell on Linux, macOS, and similar systems

    ```sh
    git clone https://github.com/lagecorp/LTR NewRepo
    rm -rf NewRepo/.git
    cd NewRepo
    git init
    ```

    The method above also works in Git Bash or Cygwin on Windows.

- On Windows Command Prompt

    ```cmd
    git clone https://github.com/lagecorp/LTR NewRepo
    rd /s /q NewRepo\.git
    cd NewRepo
    git init
    ```

- On Windows PowerShell

    ```powershell
    git clone https://github.com/lagecorp/LTR NewRepo
    Remove-Item -Recurse -Force NewRepo\.git
    Set-Location NewRepo
    git init
    ```

## Roadmap and Changelog

This repository is inspired by — but not limited to — [Keep a Changelog](https://keepachangelog.com/), [Semantic Versioning](https://semver.org/), and the [LTR](https://github.com/lagecorp/LTR) template. Any changes made, expected, or intended will be documented in the [Roadmap and Changelog](./RMAP_CLOG.md) file.

## Credits, Sponsorship, and Licensing

Developed by [Ezequiel Lage](https://github.com/ezlage) *et al*. Sponsored by [Lagecorp](https://lagecorp.com) and its subsidiaries. Published under the [MIT License](./LICENSE).  
Note: Nested materials may have their own licenses!

All feedback and contributions are welcome.

#### Follow us at [lagecorp.com](https://lagecorp.com)!