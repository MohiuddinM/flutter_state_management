## 0.10.0

- remove CreateNotifier (as it adds limited functionality, but adds complexity), now the StateNotifier can be created
  directly

## 0.9.0

- improve documentation
- remove reactive stuff

## 0.8.1

* builder can take selector with selectOnActiveOnly
* builder is now StatefulWidget

## 0.8.0

* add setActive to PersistedStateNotifier

## 0.7.2

* update readme
* rename function

## 0.7.1

* update example

## 0.7.0

* rename classed to match flutter async
* upgrade deps

## 0.6.1

* add asStream extension method for ValueListenable

## 0.6.0

* remove dependency on Isar (see example to still use it)

## 0.5.0

* state notifiers implement ValueListenable
* add extension method for state notifier

## 0.4.0

* add toString methods
* add removeFromCache
* make create method private

## 0.3.0

* add remove data options in set* methods
* add isIdle and hasCurrentData getters
* remove protected from set methods
* rename args on when method

## 0.2.0

* builder can also take idle builder

## 0.1.0

* rename isBusy to isLoading
* added loadingFuture to await when busy

## 0.0.8

* add set methods

## 0.0.7

* update docs

## 0.0.6

* replace model with void as return type

## 0.0.5

* add when and hasNoData

## 0.0.4

* fix typo

## 0.0.3

* make error generic

## 0.0.2

* Remove flutter version constraint

## 0.0.1

* Initial release.
