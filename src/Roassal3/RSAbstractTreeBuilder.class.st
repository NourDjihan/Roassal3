"
I am a abstract class to create visual elements based on tree structured in roassal3
"
Class {
	#name : #RSAbstractTreeBuilder,
	#superclass : #RSAbstractContainerBuilder,
	#instVars : [
		'rootNodes',
		'weight'
	],
	#category : #'Roassal3-Builders'
}

{ #category : #'accessing - keys' }
RSAbstractTreeBuilder >> childrenKey [
	^ #children
]

{ #category : #private }
RSAbstractTreeBuilder >> createElements: atree nesting: block1 leaves: block2 depth: depth [
	| children e leaves nodes|
	
	e := self shapeFor: atree.
	shapes add: e.
	
	children := block1 rsValue: atree.
	e attributes at: #depth put: depth.
	children := children collect: [ :child | | e2 |
		e2 := self createElements: child nesting: block1 
			leaves: block2 depth: depth + 1.
		e2 attributes at: #parent put: e.
		e2 ] as: Array.
	leaves := (block2 rsValue: atree) collect: [:child | | e2 |
		e2 := self createElements: child nesting: #() 
			leaves: #() depth: depth +1.
		e2 attributes at: #parent put: e.
		e2 ] as: Array.
	nodes := OrderedCollection new: (leaves size + children size).
	nodes addAll: children; addAll: leaves.
		
	e attributes at: self childrenKey put: nodes.
	^ e.
]

{ #category : #private }
RSAbstractTreeBuilder >> createElements: atree using: ablock depth: depth [
	| children e |
	
	e := self shapeFor: atree.
	shapes add: e.
	
	children := ablock rsValue: atree.
	e attributes at: #depth put: depth.
	children := children collect: [ :child | | e2 |
		e2 := self createElements: child using: ablock depth: depth + 1.
		e2 attributes at: #parent put: e.
		e2 ] as: Array.
	e attributes at: self childrenKey put: children.
	^ e.
]

{ #category : #'public - building' }
RSAbstractTreeBuilder >> explore: atree nesting: block1 leaves: block2 [
	^ (self from: (Array with: atree) nesting: block1 leaves: block2) first
]

{ #category : #'public - building' }
RSAbstractTreeBuilder >> explore: atree using: ablock [
	^ (self from: (Array with: atree) using: ablock) first.
	
]

{ #category : #'public - building' }
RSAbstractTreeBuilder >> from: objects nesting: block1 leaves: block2 [

	rootNodes := objects collect: [:obj | self createElements: obj nesting: block1 leaves: block2 depth: 1 ].
	
	^ rootNodes
]

{ #category : #'public - building' }
RSAbstractTreeBuilder >> from: objects using: ablock [
	"This is the main public method. Takes a list of objects, and a block to specify how to recurse"
	rootNodes := objects collect: [:obj | self createElements: obj using: ablock depth: 1 ].
	^ rootNodes
]

{ #category : #initialization }
RSAbstractTreeBuilder >> initialize [
	super initialize.
	shapes := RSGroup new.
	rootNodes := RSGroup new.
]

{ #category : #weight }
RSAbstractTreeBuilder >> leafWeight: block [
	self weight: [ :shape | self weightLeafShape: shape block: block ].
]

{ #category : #default }
RSAbstractTreeBuilder >> minWeightValue [
	^ 1
]

{ #category : #hooks }
RSAbstractTreeBuilder >> renderIn: aCanvas [
	aCanvas addAll: self shapes
]

{ #category : #accessing }
RSAbstractTreeBuilder >> rootNodes [
	^ rootNodes
]

{ #category : #accessing }
RSAbstractTreeBuilder >> rootNodes: anArray [
	rootNodes := anArray
]

{ #category : #weight }
RSAbstractTreeBuilder >> weight [
	^ weight
]

{ #category : #weight }
RSAbstractTreeBuilder >> weight: anObject [
	weight := anObject
]

{ #category : #private }
RSAbstractTreeBuilder >> weightFromChildren: shape block: aBlock [
	| children weightValue |
	children := shape attributeAt: self childrenKey.
	weightValue := children
		ifEmpty: [ aBlock rsValue: shape model ]
		ifNotEmpty: [ 
			children 
				inject: 0 
				into: [ :s :child | s + (self weightLeafShape: child block: aBlock) ] ].
	^ weightValue max: self minWeightValue.
	
]

{ #category : #'accessing - keys' }
RSAbstractTreeBuilder >> weightKey [
	^ #weight
]

{ #category : #private }
RSAbstractTreeBuilder >> weightLeafShape: shape block: aBlock [
	^ shape
		attributeAt: self weightKey
		ifAbsentPut: [ 
			self weightFromChildren: shape block: aBlock ]
]

{ #category : #weight }
RSAbstractTreeBuilder >> weightOf: aShape [
	^ self weight rsValue: aShape
]