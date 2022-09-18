function azuki-encrypt() {
	local rawfile=$1
	local zipfile="${rawfile}.zip"
	echo "encrypting ${rawfile}.."

	if [ -e ./${zipfile} ]; then
		echo "ERROR: ${zipfile} already exists"
		return 1
	fi

	local passwd=$(security find-generic-password -gs azuki -w)

	expect -c "
        set timeout 10
		spawn zip -e ${zipfile} ${rawfile}
        expect \"Enter password:\" {
            send \"${passwd}\n\"
            expect \"Verify password:\" {
                send \"${passwd}\n\"
                interact
            }
        }
        exit 0
    "
}

function azuki-decrypt() {
	local zipfile=$1
	echo "decrypting ${zipfile}.."

	local workplace="${TMPDIR}azuki/$(date +%s)"
	mkdir -p ${workplace}

	local passwd=$(security find-generic-password -gs azuki -w)

	expect -c "
        set timeout 10
		spawn unzip ${zipfile} -d ${workplace}
        expect \"password:\" {
            send \"${passwd}\n\"
			interact
        }
        exit 0
    "

	if [ -z $(ls ${workplace}) ]; then
		echo "ERROR: unzip failed, no unzipped file exists"
		return 1
	fi

	local results=$(find ${workplace} -mindepth 1 -maxdepth 1 -type f)
	for r in ${results};
	do
		resultFile=$(basename ${r})
		if [ -e ./${resultFile} ]; then
			echo "ERROR: file with the same name as the decrypted file already exists: ${resultFile}"
			return 1
		fi

		cp -p ${workplace}/${resultFile} ./${resultFile}
	done
}

function azuki() {
	# 0: auto, 1: encrypt, -1: decrypt
	local mode=0 
	local help=0

	OPTIND_OLD=$OPTIND
    OPTIND=1
	while getopts edh OPT
	do
  		case $OPT in
     	e) 
			mode=1
			;;
     	d) 
			mode=-1
			;;
	 	h|\?)
        	help=1
        	;;
  		esac
	done
	shift $(expr $OPTIND - 1)
    OPTIND=$OPTIND_OLD

	if [ ${help} -ne 0 ]; then
        echo "Usage"
		echo " Encrypt: azuki [-e] <raw file>"
		echo " Decrypt: azuki [-d] <ZIP file>"
        return
    fi

	local file=$1 

	if [ ! -f ${file} ]; then
		echo "ERROR: ${file} is not found"
		return 1
	fi


	if [ ${mode} -eq 0 ]; then
		extension=$(echo ${file##*.} |  tr "[:lower:]" "[:upper:]")
		if [ ${extension} = "ZIP" ]; then
			mode=-1
		else
			mode=1
		fi
	fi

	if [ ${mode} -gt 0 ]; then
		azuki-encrypt ${file}
	else
		azuki-decrypt ${file}
	fi
}
