#!/usr/bin/env python3

import json
import os
import numpy as np
import tensorflow as tf
import time
from tensorflow.python.client import timeline
import tensorflow.contrib.tensorrt as trt

PATH = os.path.dirname(__file__)
MODEL_FILENAME = "graph.pb"
CATEGORIES_FILENAME = "categories.json"
INPUT_SIZE = 513
INPUT_TENSOR_NAME = "ImageTensor:0"
OUTPUT_TENSOR_NAME = "SemanticPredictions:0"

class Model(object):
    def __init__(self):
        self.graph = tf.Graph()
        self.graph_def = None

        color_map_list = []
        with open(os.path.join(PATH, CATEGORIES_FILENAME)) as f:
            self._categories = json.loads(f.read())
            self._color_map = np.array([category["color"] for category in self._categories], dtype = np.uint8)

        with open(os.path.join(PATH, MODEL_FILENAME), 'rb') as f:
            self.graph_def = tf.GraphDef.FromString(f.read())

        if self.graph_def is None:
            print('Error loading graph')

        #with self.graph.as_default():
        #    tf.import_graph_def(self.graph_def, name='')

        self.trt_graph = trt.create_inference_graph(
            input_graph_def = self.graph_def,
            outputs = [OUTPUT_TENSOR_NAME.replace(":0", "")],
            max_batch_size = 100,
            max_workspace_size_bytes = 1 << 25,
            precision_mode = "FP16",
            minimum_segment_size = 3)

        with open('/tmp/trt_graph.pb', 'wb') as f:
            f.write(self.trt_graph.SerializeToString())

        self.graph = tf.Graph()
        with open('/tmp/trt_graph.pb', 'rb') as f:
            self.trt_graph = tf.GraphDef.FromString(f.read())

        self.config = tf.ConfigProto()
        self.config.gpu_options.allow_growth = True

        with self.graph.as_default():
            self.input_node, self.output_node = tf.import_graph_def(self.trt_graph, return_elements = [INPUT_TENSOR_NAME, OUTPUT_TENSOR_NAME])
        self.session = tf.Session(config = self.config, graph = self.graph)

    @property
    def trace(self):
        return (self.run_options.trace_level > 0)

    @trace.setter
    def trace(self, value):
        if value:
            self.run_options.trace_level = tf.RunOptions.FULL_TRACE
        else:
            self.run_options.trace_level = 0

    @property
    def color_map(self):
        return self._color_map

    @property
    def categories(self):
        return self._categories

    def infer(self, images):
        t = time.time()
        seg_maps = self.session.run(
            self.output_node,
            feed_dict = { self.input_node: images }
        )
        print("Inference took: %0.3f s" % (time.time() - t))

        return(seg_maps)

