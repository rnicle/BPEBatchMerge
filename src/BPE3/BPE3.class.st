Class {
	#name : 'BPE3',
	#superclass : 'Object',
	#instVars : [
		'words',
		'paires',
		'pairesPosition',
		'vocabulary',
		'merges'
	],
	#category : 'BPE3',
	#package : 'BPE3'
}

{ #category : 'adding' }
BPE3 >> addToMergesPair: aCollection mergedInto: aString [
	merges add: aCollection -> aString
]

{ #category : 'adding' }
BPE3 >> addToPaires: anAssociation [
	"self paires at: anAssociation key update: [:each| each + anAssociation value ] initial: anAssociation value"
	self paires add: anAssociation key withOccurrences: anAssociation value .
]

{ #category : 'adding' }
BPE3 >> addToPairesPosition: anAssociation [
	self pairesPosition at: anAssociation key update: [:set| set add: anAssociation value; yourself ] initial: (Set with: anAssociation value) 
]

{ #category : 'adding' }
BPE3 >> addToVocabulary: aString [
	vocabulary add: aString 
]

{ #category : 'merges' }
BPE3 >> batchMerges: anInteger [
    | numberOfFusion sorted paire i count safeFusion firstSeen lastSeen assoc left right fusionCount |
    numberOfFusion := anInteger - vocabulary size.
    fusionCount := 0.
    [ numberOfFusion > 0 ] whileTrue: [
        safeFusion := Set new.
        firstSeen := Set new.
        lastSeen := Set new.
        sorted := self paires sortedCounts.
        sorted isEmpty ifTrue: [ ^ self ].
        paire := sorted first key.
        i := 1.
        count := sorted size.
        [ i <= count and: [(sorted at: i) key = paire] ] whileTrue: [
            assoc := sorted at: i.
            left := assoc value first.
            right := assoc value second.
            ((firstSeen includes: right) not
                and: [ (lastSeen includes: left) not ]) ifTrue: [
                    safeFusion add: assoc value.
                    firstSeen add: left.
                    lastSeen add: right.
                ].
            i := i + 1.
        ].
        safeFusion do: [ :each |
            fusionCount < numberOfFusion
                ifTrue: [
                    self mergesOneStep: each.
                    fusionCount := fusionCount + 1.
                ]
                ifFalse: [ ^ self ].
        ].
        numberOfFusion := numberOfFusion - fusionCount.
    ].

]

{ #category : 'compute' }
BPE3 >> computePairs [
	|current|
	current := self words firstLink .
	[current notNil ] whileTrue: [ |prev| 
	prev:= Array new .
	[current nextLink value ~='endOfWord'] whileTrue: [
	{(current value at:1) . (current nextLink value at:1) } ~= prev ifTrue:[ |paire position |
			paire := self extractPairAndOccurencesFromCurrentNodeToNextNode: current .
			position := self extractPairAndPositionFromCurrentNodeToNextNode: current .
			self addToPaires: paire .
			self addToPairesPosition: position .
			prev :=paire key.
			]
		ifFalse: [ 
			prev:= Array new .
			 ].
			current := current nextLink .
			].
		current:=current nextLink nextLink .
		].
]

{ #category : 'compute' }
BPE3 >> computeVocabulary [ 
	|i|
	i:=words firstLink .
	[ i notNil ] whileTrue: [ 
	[ i value ~= 'endOfWord' ] whileTrue: [ 
	vocabulary add: (i value at: 1 ).
	i:= i nextLink 
	 ].
	i:= i nextLink 
	 ]
]

{ #category : 'nodes' }
BPE3 >> extractPairAndOccurencesFromCurrentNodeToNextNode: aNode [
	|pairAndOccurence|
	pairAndOccurence := ({ (aNode value at:1) . (aNode nextLink value at:1) }->(aNode value at: 2)). 
	^pairAndOccurence 
]

{ #category : 'nodes' }
BPE3 >> extractPairAndOccurencesFromPreviousNodeToCurrentNode: aNode [
	|pairAndOccurence|
	pairAndOccurence := ({ (aNode previousLink value at:1) . (aNode value at:1) }->(aNode value at: 2)). 
	^pairAndOccurence

]

{ #category : 'nodes' }
BPE3 >> extractPairAndPositionFromCurrentNodeToNextNode: aNode [
	|pairAndPosition |
	pairAndPosition := ({ (aNode value at:1) . (aNode nextLink value at:1) }->{aNode . aNode nextLink }). 
	^pairAndPosition 
]

{ #category : 'nodes' }
BPE3 >> extractPairAndPositionFromPreviousNodeToCurrentNode: aNode [
	|pairAndPosition |
	pairAndPosition := ({ (aNode previousLink value at:1) . (aNode value at:1) }->{aNode previousLink . aNode}). 
	^pairAndPosition 
]

{ #category : 'api' }
BPE3 >> fromText: anObject [
	self words: anObject .
	self computeVocabulary .
	self computePairs .
]

{ #category : 'nodes' }
BPE3 >> fusion: anArray [
	(anArray at: 1) value at: 1 put: ((anArray at:1) value at: 1) , ((anArray at: 2) value at: 1).
	words removeLink: (anArray at: 2)
	"(anArray at: 1) nextLink: (anArray at: 2) nextLink .
	(anArray at: 2) nextLink previousLink: (anArray at: 1)."
]

{ #category : 'initialize' }
BPE3 >> initialize [ 
	super initialize. 
	words :=DoubleLinkedList new.
	vocabulary := Set new.
	"paires := Dictionary new."
	paires := Bag new .
	pairesPosition := Dictionary new.
	merges:= OrderedCollection new .
]

{ #category : 'compute' }
BPE3 >> max: aDictionary [
	|max|
	max:=Association new.
	max value: 0.	
	aDictionary associationsDo: [ :each| each value > max value ifTrue:[max:=each ] ].
	^max 
]

{ #category : 'accessing' }
BPE3 >> merges [ 
	^merges 
]

{ #category : 'merges' }
BPE3 >> mergesOneStep [ 
	|paire vocabulaire|
	"paire := self max: self paires"
	paire :=self paires sortedCounts first value..
	vocabulaire:= paire first , paire second.
	"self addToMergesPair: paire key mergedInto: vocabulaire ."
	self addToMergesPair: paire mergedInto: vocabulaire .
	self addToVocabulary: vocabulaire .
	self update1: paire .
	
	
]

{ #category : 'merges' }
BPE3 >> mergesOneStep: aPaire [ 
	|vocabulaire|
	"paire := self max: self paires"
	vocabulaire:= aPaire first , aPaire second.
	"self addToMergesPair: paire key mergedInto: vocabulaire ."
	self addToMergesPair: aPaire mergedInto: vocabulaire .
	self addToVocabulary: vocabulaire .
	self update1: aPaire .
	
	
]

{ #category : 'accessing' }
BPE3 >> paires [
	^paires
]

{ #category : 'accessing' }
BPE3 >> pairesPosition [
	^pairesPosition 
]

{ #category : 'compute' }
BPE3 >> prepareWordrsFrom: anObject [
	|bag |
	(anObject isArray ) ifTrue: [ bag :=self prepareWordsFromArray:anObject ].
	(anObject isString ) ifTrue: [ bag := self prepareWordrsFromText:anObject ].
	^bag 
]

{ #category : 'compute' }
BPE3 >> prepareWordrsFromText: aText [
	"Retourne un array de tokens selon les regles:
	- lettres,chiffres et underscore restent ensemble
	-tous les autres caracteres speciaux sont des tokens separes"
	|bag currentWord|
	bag := Bag new.
	currentWord :=''.
	aText do: [ :ch | (ch isAlphaNumeric or: [ ch = $_ ])
		ifTrue:[currentWord :=currentWord, ch asString]
		 ifFalse: [currentWord isEmpty ifFalse: [
				bag add: currentWord.
				currentWord :=''.
				].
			(ch isSeparator ) ifFalse: [bag add: ch asString].
			].
		].
	currentWord isEmpty ifFalse: [ bag add: currentWord ].
	^bag
]

{ #category : 'as yet unclassified' }
BPE3 >> prepareWordsFromArray:anArray [
	|bag|
	bag := anArray asBag .
	^bag 
]

{ #category : 'compute' }
BPE3 >> setOfFrequencyPair [
	|frequencyPair sorted set i |
	set := Set new.
	sorted :=self paires sortedCounts .
	frequencyPair := sorted first.
	i:=1.
	(i<= sorted size and: [(sorted at: i) = frequencyPair]) whileTrue: [ :each| set add: (sorted at: i ) . i:= i+1 ].
	^set 
	
	
	
]

{ #category : 'as yet unclassified' }
BPE3 >> update1: anAssociation [
	|position|
	"position := self pairesPosition at: anAssociation key."
	position := self pairesPosition at: anAssociation .
	position do: [ :each| |left right prev next| 
		left := each first.
		right := each second.
		prev := left previousLink .
		next := right nextLink .
		prev ifNotNil: [ 
			prev value ~= 'endOfWord' ifTrue: [ 
				self updatePaires:(self extractPairAndOccurencesFromPreviousNodeToCurrentNode:left ).
				self updatePairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: left ).
				 ].
			 ].
		next ifNotNil: [ 
			next value ~= 'endOfWord' ifTrue: [ 
				self updatePaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: right ).
				self updatePairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: right)
				 ].
			 ] .
		self fusion: each .
		prev ifNotNil: [ 
			prev value ~='endOfWord' ifTrue: [ 
				self addToPaires: (self extractPairAndOccurencesFromPreviousNodeToCurrentNode: left ).
				self addToPairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: left ).
				 ].
			 ].
		next ifNotNil: [ 
			next value ~= 'endOfWord' ifTrue: [ 
				self addToPaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: left ).
				self addToPairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: left ).
				 ].
			 ].
		].
	"self paires removeKey: anAssociation key ifAbsent: [  ]."
	self paires removeKey: anAssociation ifAbsent: [  ].
	"self pairesPosition removeKey: anAssociation key ifAbsent: [  ]."
	self pairesPosition removeKey: anAssociation ifAbsent: [  ].
]

{ #category : 'updating' }
BPE3 >> update: anAssociation [
	|position|
	position:= self pairesPosition at: anAssociation key.
	position do:[ :each |	
		((each first) previousLink value isNotNil and: [ (each first) previousLink value ~= 'endOfWord' ])
		ifTrue: [ 
			(each second) nextLink value ~='endOfWord' 
			ifTrue: [
				"suppression des anciens paires"
				self updatePaires: (self extractPairAndOccurencesFromPreviousNodeToCurrentNode: (each first)).
				self updatePairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: (each first)).
				self updatePaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: (each second)).
				self updatePairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: (each second)).
				"fusion"
				self fusion: each .
				"ajouts des nouveaux paires"
				self addToPaires: (self extractPairAndOccurencesFromPreviousNodeToCurrentNode: (each first)).
				self addToPairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: (each first)).
				self addToPaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: (each first)).
				self addToPairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: (each first)).
				] 
			ifFalse: [
				"suppression des anciens paires"
				self updatePaires: (self extractPairAndOccurencesFromPreviousNodeToCurrentNode: (each first)).
				self updatePairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: (each first)).
				"fusions"
				self fusion: each .
				"ajouts des nouveaux paires"
				self addToPaires: (self extractPairAndOccurencesFromPreviousNodeToCurrentNode: (each first)).
				self addToPairesPosition: (self extractPairAndPositionFromPreviousNodeToCurrentNode: (each first)).
				] 
			 ]
		
		 ifFalse: 
			[(each second) nextLink value ~= 'endOfWord' 
			ifTrue: [ 
				"suppression des anciens paires"
				self updatePaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: (each second)).
				self updatePairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: (each second)).
				"fusions"
				self fusion: each .
				"ajouts des nouveaux paires"
				self addToPaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: (each first)).
				self addToPairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: (each first)).
				 ] 
			ifFalse: [
				"suppresions des anciens paires"
				self updatePaires: (self extractPairAndOccurencesFromCurrentNodeToNextNode: (each first)).
				self updatePairesPosition: (self extractPairAndPositionFromCurrentNodeToNextNode: (each first)).
				"fusions"
				self fusion: each
				].
			].
		].
	self paires removeKey: anAssociation key ifAbsent: [].
	self pairesPosition removeKey: anAssociation key ifAbsent: [].
]

{ #category : 'update' }
BPE3 >> updatePaires: anAssociation [
	"self paires at: anAssociation key update: [:each| each - anAssociation value ]."
	self paires add: anAssociation key withOccurrences: anAssociation value negated .
	"(paires at: anAssociation key) = 0 ifTrue: [ paires removeKey: anAssociation key ]"
	(paires occurrencesOf: anAssociation key) = 0 ifTrue: [ paires removeKey: anAssociation key ifAbsent: []]
]

{ #category : 'update' }
BPE3 >> updatePairesPosition: anAssociation [
	self pairesPosition at: anAssociation key update: [:set| set remove: anAssociation value ifAbsent:[] ; yourself ].
	(self pairesPosition at: anAssociation key)size =0 ifTrue: [ self pairesPosition removeKey: anAssociation key ]
	 
]

{ #category : 'accessing' }
BPE3 >> vocabulary [ 
	^vocabulary
]

{ #category : 'accessing' }
BPE3 >> words [
	^words 
]

{ #category : 'compute' }
BPE3 >> words: anObject [
	|text|
	text:=self prepareWordrsFrom: anObject .
	text associationsDo: [ :each|
			each key do:[:char|
			words add: { char asString . each value}]. words add: {'</t>' . each value}. words add:'endOfWord' ].
	^words
]
