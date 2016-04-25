#https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/skflow/iris_val_based_early_stopping.py
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from sklearn import datasets, metrics
from sklearn.cross_validation import train_test_split

from tensorflow.contrib import skflow


iris = datasets.load_iris()
X_train, X_test, y_train, y_test = train_test_split(iris.data,
                                                    iris.target,
                                                    test_size=0.2,
                                                    random_state=42)

X_train, X_val, y_train, y_val = train_test_split(X_train, y_train,
                                                  test_size=0.2, random_state=42)
val_monitor = skflow.monitors.ValidationMonitor(X_val, y_val,
                                                print_steps=100,
                                                early_stopping_rounds=200,
                                                n_classes=3)

# classifier with early stopping on training data
classifier1 = skflow.TensorFlowDNNClassifier(hidden_units=[10, 20, 10],
                                             n_classes=3, steps=10)
classifier1.fit(X_train, y_train)
score1 = metrics.accuracy_score(y_test, classifier1.predict(X_test))

# classifier with early stopping on validation data
classifier2 = skflow.TensorFlowDNNClassifier(hidden_units=[10, 20, 10],
                                             n_classes=3, steps=1000)
classifier2.fit(X_train, y_train, val_monitor)
score2 = metrics.accuracy_score(y_test, classifier2.predict(X_test))

# in many applications, the score is improved by using early stopping on val data
print('test score after {} steps {}, after {} steps (early stopping) {}'.format(
    classifier1._monitor.steps, score1, classifier2._monitor.steps, score2))
    
plt.figure;
plt.plot(val_monitor.all_train_loss_buffer);
plt.plot(val_monitor.all_val_loss_buffer);
plt.show()
