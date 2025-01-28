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
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' do: [:letter |
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
        file := FileStream readOnlyFileNamed: fileName.

        [file atEnd] whileFalse: [
            line := file nextLine.
            charCount := charCount + line size.
            line isEmpty ifFalse: [ lineCount := lineCount + 1 ].

            "Split the line into words"
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

    "Helper Method: Print Dictionary with Frequencies"
    printDictionaryWithFrequencies [
        Transcript show: '/------------\' withCRs.
        Transcript show: '| Dictionary |' withCRs.
        Transcript show: '\------------/' withCRs.

        wordFreq associations do: [:entry |
            Transcript show: entry key, ' : ', entry value asString; cr.
        ].
    ]

    "Display Statistics"
    displayStatistics [
        Transcript show: 'Number of Characters: ', charCount asString; cr.
        Transcript show: 'Number of Words: ', wordCount asString; cr.
        Transcript show: 'Number of Lines: ', lineCount asString; cr.

        self printDictionaryWithFrequencies.
    ]

    "Run the Assignment"
    runAssignment: fileName [
        self initialize.
        self processFile: fileName.
        self displayStatistics.
    ]
].

"Run the script"
| assignment |
assignment := DictionaryAssignment new.
assignment runAssignment: 'data.txt'.
