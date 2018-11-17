# NXboard
A copy of the Nintendo Switch keyboard for LovePotion.

![Preview](https://www.dropbox.com/s/t6cum2br2fwy94h/NXboard_preview.jpg?dl=1)
# Preparation
**You will need the latest _nightly_ LovePotion.elf for Switch!**

Download the latest [NXboard.zip](https://github.com/tallbl0nde/NXboard/releases/latest) and extract the contents to your _game_ directory.
_If you wish to change the location of the resources folder, make sure you change the 'path variable' in NXboard.lua_ 

Set up your main.lua as seen in [template.lua](https://github.com/tallbl0nde/NXboard/blob/master/template.lua) so that appropriate events are passed to NXboard.
# Usage
To invoke the keyboard use `[name]:init(var, buffer, theme, type, omit_keys, char_limit, message)` where the arguments are as follows:
* var: A string containing the name of the variable to return/copy the buffer to when the keyboard is closed
* buffer: A string (can be a variable) containing the contents of the keyboard buffer when invoked
* theme: A string (either "dark" or "light") which sets the theme of the keyboard
* type: A string (either "keyboard" or "numpad") which sets which layout is shown
* omit_keys: A table containing single characters that will not be allowed to be typed (valid examples are {} [allow all] or {'a','b','c'} [allow everything but a, b or c] or {"only_numbers"} [only numbers will be allowed])
* char_limit: A number specifying the maximum length of the keyboard buffer allowed
* message: A string to display when the buffer is empty

_You will most likely call this in touch/gamepad events as seen in the examples_

For example, if you wanted to store the user's input in the variable _p1_number_, and open a dark numpad with a limit of 10 digits, allowing only numbers to be entered you would type something similar to:
`[name]:init("p1_number",p1_number,"dark","numpad",{"only_numbers"},10,"Enter a 10 digit number...")` 
