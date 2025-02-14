# install arch packages
yay -S $(cat ./packagelist.txt)

# change default shell
chsh -s /bin/zsh
