In Godot 4, the script editor automatically highlights several keywords (referred to as *comment markers*) when they are used inside comments (`\#`). These words are divided into three priority and color categories:


🔴 Critical (Usually Red)

Used for safety alerts or critical errors needing immediate attention:

- **ALERT**

- **ATTENTION**

- **CAUTION**

- **CRITICAL**

- **DANGER**

- **SECURITY** 

🟡 Warning (Usually Yellow/Orange)

Used for pending tasks, known bugs, or code sections needing review:

- **BUG**

- **DEPRECATED**

- **FIXME**

- **HACK**

- **TASK**

- **TBD** (To Be Determined)

- **TODO**

- **WARNING** 

🔵 Informational (Usually Blue/Green)

Used for general notes, tests, or less urgent notices:

- **INFO**

- **NOTE**

- **NOTICE**

- **TEST**

- **TESTING** 

Important Tips:

- **Case Sensitivity**: These keywords are **case-sensitive**; they will only be highlighted if they are in uppercase letters.

- **Single-Line Comments Only**: The highlighting works in single-line comments (`\#`). It generally does not work in multi-line strings (`"""`), which Godot technically treats as strings and not as pure comments.

- **Customization**: You can find and edit these lists in the **Editor Settings** under `Text Editor \> Theme \> Highlighting \> Comment Markers`.
