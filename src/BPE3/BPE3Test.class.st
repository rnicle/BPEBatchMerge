Class {
	#name : 'BPE3Test',
	#superclass : 'TestCase',
	#category : 'BPE3',
	#package : 'BPE3'
}

{ #category : 'accessing' }
BPE3Test >> array [ 
	^ {'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'old' . 'older' . 'older' . 'older' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'finest' . 'lowest' . 'lowest' . 'lowest' . 'lowest'}
]

{ #category : 'tests' }
BPE3Test >> testBuildVocabularyProducesCorrectVocabulary [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text.
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPE3Test >> testBuildVocabularyProducesCorrectVocabularyFromArray [

	| enc |
	enc := BPE3 new. 
	enc fromText: self array .
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPE3Test >> testBuildVocabularyProducesCorrectVocabularyText2 [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text2.
	enc computeVocabulary.
	self assertCollection: enc vocabulary asSet hasSameElements: { '</t>' . 'd' . 'e' . 'i' . 'l' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
BPE3Test >> testComputePairs [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text.
	
	self assert: (enc paires occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc paires occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc paires keys size equals: 15
]

{ #category : 'tests' }
BPE3Test >> testComputePairsArray [

	| enc |
	enc := BPE3 new. 
	enc fromText: self array .
	
	self assert: (enc paires occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc paires occurrencesOf: {'t' . '</t>'}) equals: 13. 
	
	self assert: enc paires keys size equals: 15
]

{ #category : 'tests' }
BPE3Test >> testComputePairsText2 [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text2.
	
	self assert: (enc paires occurrencesOf: {'e' .'s'}) equals: 9. 
	self assert: (enc paires occurrencesOf: {'i'. 'd'}) equals: 3. 
	self assert: (enc paires occurrencesOf: {'o' .'w'}) equals: 7. 
	self assert: (enc paires occurrencesOf: {'s'. 't'}) equals: 9. 
	self assert: (enc paires occurrencesOf: {'w'. 'e'}) equals: 8. 
	self assert: (enc paires occurrencesOf: {'w'. 'i'}) equals: 3. 
	self assert: (enc paires occurrencesOf: {'t'.'</t>'}) equals: 9. 

	 "#('lo' 't_' 'er' 'r_' 'st' 'wi' 'es' 'ne' 'ow' 'we' 'w_' 'id' 'de' 'ew')"
	self assert: enc paires keys size equals: 14
]

{ #category : 'tests' }
BPE3Test >> testMergeOneStepAddMergeToMergeList [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text.
	enc computeVocabulary.
	
	self assert: enc merges isEmpty.
	enc mergesOneStep .
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'
]

{ #category : 'tests' }
BPE3Test >> testMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPE3 new. 
	enc fromText: self text.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	self assert: (enc vocabulary includes: 't</t>').
	self assert: enc merges size equals: mergeOldSize + 1.
	self assert: enc vocabulary size equals: 13
]

{ #category : 'tests' }
BPE3Test >> testMergeOneStepRecomputePairs [

	| enc|
	enc := BPE3 new. 
	enc fromText: self text.
	
	enc mergesOneStep .
	
	self assert: (enc paires occurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc paires occurrencesOf: {'s' . 't</t>'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc paires occurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc paires occurrencesOf: {'w' . 'e'}) equals: 4. 
	self assert: (enc paires occurrencesOf: {'n' . 'e'}) equals: 9. 
]

{ #category : 'tests' }
BPE3Test >> testTwoMerges [

	| enc |
	enc := BPE3 new. 
	enc fromText: self text.
	enc computeVocabulary.
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: enc merges first equals: #('t' '</t>')->'t</t>'. 
	self assert: enc merges second equals: #('e' 's')->'es'. 
]

{ #category : 'accessing' }
BPE3Test >> text [
	^ 'old old old old old old old 
older older older
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'
]

{ #category : 'accessing structure variables' }
BPE3Test >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]
