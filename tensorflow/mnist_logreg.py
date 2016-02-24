"""MNIST classifier using logistic regression.
Based on github/tensorflow/tensorflow/examples/tutorials/mnist/mnist_softmax.py
"""
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

# Import data
from tensorflow.examples.tutorials.mnist import input_data

import tensorflow as tf

mnist = input_data.read_data_sets("/tmp/data/", one_hot=True)

# The MNIST dataset has 10 classes, representing the digits 0 through 9.
NUM_CLASSES = 10

# The MNIST images are always 28x28 pixels.
IM_SIZE = 28
IM_PIXELS = IM_SIZE * IM_SIZE

sess = tf.InteractiveSession()

# Create the model
X = tf.placeholder(tf.float32, [None, IM_PIXELS])
W = tf.Variable(tf.zeros([IM_PIXELS, NUM_CLASSES]))
b = tf.Variable(tf.zeros([NUM_CLASSES]))
y_pred = tf.nn.softmax(tf.matmul(X, W) + b)

# Define loss and optimizer
y_true = tf.placeholder(tf.float32, [None, NUM_CLASSES])
# Neg. log likelihood. Assumes y_true is one-hot encoded
cross_entropy = -tf.reduce_sum(y_true * tf.log(y_pred))
train_step = tf.train.GradientDescentOptimizer(0.01).minimize(cross_entropy)

# Train
tf.initialize_all_variables().run()
for i in range(1000):
  batch_xs, batch_ys = mnist.train.next_batch(100)
  # batch_ys has shape  B * 10, where each row is one-hot encoded
  if i % 100 == 0:
      print("step {}".format(i))
  train_step.run({X: batch_xs, y_true: batch_ys})

# Test trained model
correct_prediction = tf.equal(tf.argmax(y_pred, 1), tf.argmax(y_true, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
test_accuracy = accuracy.eval({X: mnist.test.images, y_true: mnist.test.labels})
print("test accuracy {0:0.2f}".format(test_accuracy))
assert isclose(test_accuracy, 0.91, 1e-2), (
    'test accuracy should be 0.91, is %f' % test_accuracy)

