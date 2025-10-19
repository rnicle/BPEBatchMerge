Extension { #name : 'Bag' }

{ #category : '*BPE3' }
Bag >> keys [

	^ contents keys
]

{ #category : '*BPE3' }
Bag >> removeKey: oldObject ifAbsent: exceptionBlock [ 
	"Remove oldObject's entry (e.g., the object and all its occurrences) from the receiver's elements.
	If no element is equal to oldObject, answer the result of evaluating anExceptionBlock. 
	Otherwise, answer the argument, oldObject."

	| count |
	count := contents at: oldObject ifAbsent: [^ exceptionBlock value].
	contents removeKey: oldObject.
	^ oldObject
]
