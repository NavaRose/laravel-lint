# AMV Lint
Check coding convention, coding consistency for your laravel project.

## **Install**

Run follow command in root directory of your laravel project:  
``composer require amv-hub/amv-lint --dev``
  

After package installed, run following command to initialize the package config:  
``./vendor/amv-hub/amv-lint/init.sh --dev``


## **Usage**
After package installed, to lint your project included **checking env variable**, **checking language translation file**s, 
check **coding consistency** and **coding convention** of **JavaScript**, **PHP**, please run following command:  
``amv lint``
  

For checking individually for each feature, please provide a third parameter, included `env`, `lang`, `php`, `js`:  
``amv lint env``  
``amv lint lang``  
``amv lint php``  
``amv lint js``  
  
  
By default, the checking execution will stop when first error occurs. Sometimes, you need the checking execution doesn't
stop until the end. So, just provide `-g` flag for execution command. Notice: if you provide the individual feature for checking, 
please place `-g` flag just before the name of checking feature.  
``amv lint -g``  
``amv lint -g env``  
``amv lint -g lang``  
``amv lint -g php``  
``amv lint -g js``  

## **Configurations**
The general configurations file is `.amv_lint.env`, which was placed is your project root folder. It contains 
various environment variable. These following features are the most important you should know.

### DEBUG_MODE:
When you turn this variable to `true`, it will work same way when you turn `-g` flag in your checking command.
But this variable will be ignored when you provide -g flag. For example, if you set this DEBUG_MODE to false, 

### CHECKING_STANDARDS:
This is the list of PHP standards for checking execution. Standards are separated by a comma `,` and you can provide a following standards:
`psr1`, `psr2`, `psr12`, `pear`.

### IS_STAGED_CHECKING:
If set it true, the checking execution will perform a check with the staged files (the files that you added it for commit). 
Otherwise, if you set this variable to false, these following folder will be checked:
- ENV variable checking: folders which represent in `ENV_USING_CHECKING_DIRS` variable.
- For PHP files checking: folders which represent in `PHP_CONVENTION_CHECKING_DIRS` variable.
- For JavaScript checking: folders which represent in `JS_CONVENTION_CHECKING_DIRS` variable.

These variable's value is string of one or many folders, separated by a comma `,`
