check_execution_time_of_a_process_in_linux()
{
echo -e "
# How to Check Execution Time of a Process in Linux
 
Command time:
${shell_color_palette[bwhite_on_black]}$ time du -hs /root/${shell_color_palette[color_off]}
464K /root/
real 0m0.007s
user 0m0.002s
------------------

Command ps:

${shell_color_palette[bold]}To identify process ID, you can use a tool like pidof${shell_color_palette[color_off]}

Check running process time using ps

${shell_color_palette[bwhite_on_black]}$ pidof firefox${shell_color_palette[color_off]}
1388

Then use ps with options -o etime to find elapsed running time.

${shell_color_palette[bwhite_on_black]}$ ps -p 1388 -o etime${shell_color_palette[color_off]}

ELAPSED
 05-11:03:02

------------------
${shell_color_palette[bold]}etime${shell_color_palette[color_off]} option displays elapsed time since the process was started, in the form [[DD-]hh:]mm: ss. So from above example,
the process has been running for ${shell_color_palette[bold]}5${shell_color_palette[color_off]} days, ${shell_color_palette[bold]}1${shell_color_palette[color_off]}1 hours and ${shell_color_palette[bold]}3${shell_color_palette[color_off]} minutes. Use ${shell_color_palette[bold]}etimes${shell_color_palette[color_off]} option to get elapsed time in seconds.

This command option can also be used for multiple processes. The example below will display start time and the execution
time of all processes on my Ubuntu server.

${shell_color_palette[bwhite_on_black]}$ ps -eo pid,lstart,etime,args${shell_color_palette[color_off]}

${shell_color_palette[green]}See more:${shell_color_palette[color_off]}
https://linuxopsys.com/topics/check-execution-time-of-a-process-linux

" #| less
}

