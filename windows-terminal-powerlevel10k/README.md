# Make your WSL or WSL2 terminal awesome - with Windows Terminal, zsh, oh-my-zsh and Powerlevel10k

In this video, I will show you how you make your WSL or WSL2 terminal just awesome! We will install and configure Windows Terminal, zsh, oh-my-zsh, and Powerlevel10k theme.

Video: https://youtu.be/235G6X5EAvM

## Prerequisites

- Windows Subsystem for Linux, running on Windows 10 or newer

## Installation and Configuration

### Install Windows Terminal

https://docs.microsoft.com/en-us/windows/terminal/install

### Install Nerd Fonts

To make Windows Terminal able to render the icons we're using in **zsh** later, we need to install the **Nerd-Fonts** on Windows. First, go to the Nerd-Font homepage and select a Font you like. Note that not all of them work well with all zsh themes, you may need to try out different ones. Fonts that work for me are **Anonymice Nerd Font**, **Droid Sans Mono Nerd Font**, and **Hack Nerd Font**. Then, extract the archive and install all of the `.otf` Font files.

https://www.nerdfonts.com/

### Install zsh shell in WSL / WSL2

Now we need to install the **zsh** shell in our wsl or wsl2. You can easily install it in the Ubuntu wsl by using the commands below. If you're using a different Linux distribution, you may check out the zsh documentation or your package a documentation.

We will also install **oh-my-zsh** which is a nice configuration extension to the **zsh** shell. That will allow us to easily customize anything, install a theme, and add plugins later.

```bash
sudo apt update

sudo apt install zsh -y

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Install powerlevel10k zsh theme

Next, we will install the powerlevel10k theme, which really looks nice and offers great customization features. It also has a good configuration wizard that makes it extremely easy to set up the theme for your favorite design.

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

To activate the theme you need to edit your `~/.zshrc` file in your personal folder and replace `ZSH_THEME="robbyrussel` with `ZSH_THEME="powerlevel10k/powerlevel10k`. After the change, you need to close and restart your terminal.

### Change Windows Terminal settings to use Nerd-Fonts

Because we want Windows Terminal to be able to render the icons in the powerlevel10k theme correctly, we need to change the Windows Terminal configuration to use the Nerd-Font we've downloaded before. Click on **Settings** in the Windows Terminal menu and edit the `settings.json` file with your favorite text editor.

Find your wsl or wsl2 profile and add the line `"fontFace": "<name-of-your-font>"`.

### (Optional) How to install or enable plugins in zsh

**Example: Auto-suggestion plugin**

I found this nice auto-suggestion plugin for the **zsh** shell. Above all, it's really nice and helps me a lot when working with the Linux terminal. It will suggest you auto-completes based on your command history.

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

To enable the auto-suggestion plugin or any other plugins in **zsh**, edit your `~/.zshrc` file in your personal folder. Simply change the default line `plugins=(git)` to `plugins=(git zsh-autosuggestions <optional-other-plugins>)`. Of course, replace the `<optional-other-plugins>` with any other plugins you want to enable.