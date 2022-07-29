#!/bin/zsh

animation_frame_interval=0.3

# loadig animation arrays
classic=('-' "\\" '|' '/')

cloning=( 'cloning   ' 'cloning.  ' 'cloning.. ' 'cloning...')

loading=('loading   ' 'loading.  ' 'loading.. ' 'loading...')

waiting=('waiting   ' 'waiting.  ' 'waiting.. ' 'waiting...')

installing=('installing   ' 'installing.  ' 'installing.. ' 'installing...')

building=('building   ' 'building.  ' 'building.. ' 'building...')

configuring=('configuring   ' 'configuring.  ' 'configuring.. ' 'configuring...')

cleaning=('cleaning   ' 'cleaning.  ' 'cleaning.. ' 'cleaning...')

metro=(	'[                        ]'
		'[=                       ]'
		'[==                      ]'
		'[===                     ]'
		'[====                    ]'
		'[=====                   ]'
		'[======                  ]'
		'[=======                 ]'
		'[========                ]'
		'[=========               ]'
		'[==========              ]'
		'[===========             ]'
		'[============            ]'
		'[ ============           ]'
		'[  ============          ]'
		'[   ============         ]'
		'[    ============        ]'
		'[     ============       ]'
		'[      ============      ]'
		'[       ============     ]'
		'[        ============    ]'
		'[         ============   ]'
		'[          ============  ]'
		'[           ============ ]'
		'[            ============]'
		'[             ===========]'
		'[              ==========]'
		'[               =========]'
		'[                ========]'
		'[                 =======]'
		'[                  ======]'
		'[                   =====]'
		'[                    ====]'
		'[                     ===]'
		'[                      ==]'
		'[                       =]' )

declare -a BLA_active_loading_animation

play_loading_animation_loop() {
	while true ; do
		for frame in "${active_loading_animation[@]}" ; do
			printf "\r%s" "${frame}"
			sleep $animation_frame_interval
		done
	done
}

start_loading_animation() {
	active_loading_animation=( "${@}" )
	# Hide the terminal cursor
	tput civis
	# run loading loop on sub-shell
	play_loading_animation_loop &
	# get loading loop pid
	loading_animation_pid="${!}"
}

stop_loading_animation() {
	# kill background process
	kill "${loading_animation_pid}" &> /dev/null
	printf "\n"
	# Restore the terminal cursor
	tput cnorm
}