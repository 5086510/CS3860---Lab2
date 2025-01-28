Object subclass: DictionaryAssignment [

    | charCount wordCount lineCount letterFreq wordFreq uniqueWords |

    "Initialization Method"
    initialize [
        charCount := 0.
        wordCount := 0.
        lineCount := 0.
        letterFreq := Dictionary new.
        wordFreq := Dictionary new.
        uniqueWords := Set new.

        "Initialize letter frequencies for a-z and A-Z"
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' do: [:letter |
            letterFreq at: letter put: 0.
        ].
        'abcdefghijklmnopqrstuvwxyz' do: [:letter |
            letterFreq at: letter put: 0.
        ].
    ]

    "Helper Method: Split a String into Words"
    splitIntoWords: aString [
        | delimiters wordList currentWord |
        delimiters := ' .,;!?-@#$%^&*()[]{}<>|/\\+=~:''"0123456789'.
        wordList := OrderedCollection new.
        currentWord := ''.

        aString do: [:ch |
            (delimiters includes: ch)
                ifTrue: [
                    currentWord isEmpty ifFalse: [
                        wordList add: currentWord.
                        currentWord := ''.
                    ].
                ]
                ifFalse: [ currentWord := currentWord, ch asString ].
        ].

        "Add the last word if any"
        currentWord isEmpty ifFalse: [ wordList add: currentWord ].

        ^ wordList asArray
    ]

    "Helper Method: Process File"
    processFile: fileName [
        | file line words |
        file := FileStream open: fileName mode: #read.

        [file atEnd] whileFalse: [
            line := file nextLine.
            charCount := charCount + line size.
            line isEmpty ifFalse: [ lineCount := lineCount + 1 ].

            "Split the line into words using the splitIntoWords: helper"
            words := self splitIntoWords: line.
            words do: [:word |
                wordCount := wordCount + 1.
                uniqueWords add: word.

                "Update word frequency"
                wordFreq at: word ifAbsentPut: [ 0 ].
                wordFreq at: word put: ((wordFreq at: word) + 1).

                "Update letter frequency"
                word do: [:letter |
                    letterFreq at: letter ifAbsentPut: [ 0 ].
                    letterFreq at: letter put: ((letterFreq at: letter) + 1).
                ].
            ].
        ].
        file close.

    ]

    "Helper Method: Print Letter Histogram"
    printLetterHistogram [
        '/--------------\' displayNl.
        '|  Letter Freq |' displayNl.
        '\--------------/' displayNl.

        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' , 'abcdefghijklmnopqrstuvwxyz' do: [:letter |
            | count bar |
            count := letterFreq at: letter ifAbsent: 0.
            bar := String new: (count min: 10).
            1 to: (count min: 10) do: [:i | bar at: i put: $*].
            Transcript show: letter asString, ' | ', bar.
            count > 10 ifTrue: [
                (' (', (count - 10) asString, ')') display.
            ].
            Transcript cr.
        ].
    ]

    "Helper Method: Print Word Histogram"
    printWordHistogram [
        | maxWordLength maxFreq sortedWords dashCount stPoc dashIncrement |
        '/--------------\' displayNl.
        '|   Histogram  |' displayNl.
        '\--------------/' displayNl.

        "Sort words by frequency"
        sortedWords := wordFreq associations
              sorted: [:a :b | a value > b value ].

        maxWordLength := (sortedWords collect: [:entry | entry key size ]) inject: 0 into: [:max :each | max max: each].
        maxFreq := (sortedWords collect: [:entry | entry value]) inject: 0 into: [:max :each | max max: each].
        dashCount := (maxWordLength * 2) + (sortedWords size * 2).
	
	stPoc := ((maxWordLength * 2) + 1).


	maxFreq to: 1 by: -1 do: [:row |
            Transcript show: (self repeatedString: $  count: stPoc).

            sortedWords do: [:entry |
                (entry value >= row) ifTrue: [ Transcript show: '* ' ] 
                ifFalse: [ Transcript show: ' ' ]. 
            ]. 
            Transcript cr.
        ].

        Transcript show: (self repeatedString: $- count: dashCount); cr.

	Transcript show: (self repeatedString: $  count: ((maxWordLength * 2) + 1)).

        1 to: ((dashCount - (maxWordLength * 2)) // 2) do: [:i |
               Transcript show: '^ '.
        ].

	Transcript cr.


	dashIncrement := maxWordLength + 1.
        sortedWords do: [:entry |
            | padding paddedWord |
            padding := String new: (maxWordLength - entry key size).
            1 to: padding size do: [:i | padding at: i put: $ ].
            paddedWord := entry key asString , padding.
            Transcript show: paddedWord.
            Transcript show:  '', (self repeatedString: $- count: dashIncrement), '/ '.
            1 to: ((dashCount - (dashIncrement) - maxWordLength)) // 2 do: [:i |
                  Transcript show: '| '.
            ].
            Transcript cr.
	    dashIncrement := dashIncrement + 2.
        ].


    ]

    "Helper Method: Repeated String"
    repeatedString: aCharacter count: n [
        | result |
        result := String new: n.
        1 to: n do: [:i | result at: i put: aCharacter].
        ^ result.
    ]

    "Helper Method: Print Dictionary with Frequencies"
    printDictionaryWithFrequencies [
         '/------------\' displayNl.
         '| Dictionary |' displayNl.
         '\------------/' displayNl.
         'Word          Frequency' displayNl.
         '-----------------------' displayNl.

         wordFreq associations do: [:entry |
                | word frequency formattedRow |
                word := entry key.
                frequency := entry value asString.

                "Format the row: left-align word, right-align frequency"
                formattedRow := word , (String new: (22 - word size) withAll: $ ) , frequency.

                formattedRow displayNl.
         ].

    ]


    "Display Statistics"
    displayStatistics [
        | wordString |
        wordString := String streamContents: [:stream |
            uniqueWords asArray do: [:word |
                stream nextPutAll: word; nextPutAll: ', '.
            ].
        ].
        "Remove the trailing ', ' if there are words"
        wordString := wordString copyFrom: 1 to: wordString size - 2.
        Transcript show: 'Words in dictionary: ', wordString; cr.

        Transcript show: 'Number of Characters: ', charCount asString; cr.
        Transcript show: 'Number of Words: ', wordCount asString; cr.
        Transcript show: 'Number of Lines: ', lineCount asString; cr.

        self printLetterHistogram.
        self printDictionaryWithFrequencies.
        self printWordHistogram.
    ]

    "Run the Assignment"
    runAssignment: fileName [
        self initialize.
        self processFile: fileName.
        self displayStatistics.
    ]
].

"Run the script"
| assignment fileName |

"Prompt the user to enter a filename"
Transcript show: 'Enter the name of the file: '.
fileName := FileStream stdin nextLine.

"Create an instance and run the assignment with the provided filename"
assignment := DictionaryAssignment new.
assignment runAssignment: fileName.
