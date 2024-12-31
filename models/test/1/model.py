# import json
import torch
import numpy as np
# import torch
# import torchaudio
# from transformers import Wav2Vec2Model, Wav2Vec2Processor
import triton_python_backend_utils as pb_utils


class TritonPythonModel:
    def initialize(self, args):
        self.sample_rate = 16000
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    def execute(self, requests):
        responses = []
        for request in requests:
            input_string = pb_utils.get_input_tensor_by_name(request, "INPUT").as_numpy()

            input_string = input_string.tobytes().decode("utf-8")

            output_string = input_string.upper()

            output_tensor = pb_utils.Tensor("OUTPUT", np.array([output_string.encode("utf-8")]))
            responses.append(pb_utils.InferenceResponse(output_tensors=[output_tensor]))

        return responses
    
    def finalize(self):
        print('Cleaning up...')
