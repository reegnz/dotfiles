au BufRead,BufNewFile ~/.aws/config setfiletype confini
au BufRead,BufNewFile ~/.aws/credentials setfiletype confini
" set by AWS_CONFIG_FILE env var
au BufRead,BufNewFile ~/.config/aws/config setfiletype confini
" set by AWS_SHARED_CREDENTIALS_FILE env var
au BufRead,BufNewFile ~/.config/aws/credentials setfiletype confini

" saml2aws
au BufRead,BufNewFile ~/.saml2aws setfiletype confini
" set by SAML2AWS_CONFIGFILE env var
au BufRead,BufNewFile ~/.config/saml2aws/config setfiletype confini

" gimme-aws-creds
au BufRead,BufNewFile ~/.okta_aws_login_config setfiletype confini
" set by OKTA_CONFIG env var
au BufRead,BufNewFile ~/.config/gimme-aws-creds/config setfiletype confini
