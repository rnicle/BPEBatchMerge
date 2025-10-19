Class {
	#name : 'BaselineOfBPE3',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPE3',
	#package : 'BaselineOfBPE3'
}

{ #category : 'baselines' }
BaselineOfBPE3 >> baseline: spec [
    <baseline>
    spec for: #common do: [
			spec
				package: #'BPE3'.
			spec
				group: 'Core' with: #( 'BPE3' );
				group: 'default'
				with: #( 'BPE3' ) ]
]
