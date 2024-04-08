#!/bin/bash

# Variables
source ./00-variables.sh

url="https://$falconSubdomain.$dnsZoneName/chat"

result=$(curl -X POST \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{
        "prompt":"Tell me about Tuscany and its cities.",
        "return_full_text": false,
        "clean_up_tokenization_spaces": true, 
        "prefix": null,
        "handle_long_generation": null,
        "generate_kwargs": {
                "max_length":4096,
                "min_length":0,
                "do_sample":true,
                "early_stopping":false,
                "num_beams":1,
                "num_beam_groups":1,
                "diversity_penalty":0.0,
                "temperature":1.0,
                "top_k":10,
                "top_p":1,
                "typical_p":1,
                "repetition_penalty":1,
                "length_penalty":1,
                "no_repeat_ngram_size":0,
                "encoder_no_repeat_ngram_size":0,
                "bad_words_ids":null,
                "num_return_sequences":1,
                "output_scores":false,
                "return_dict_in_generate":false,
                "forced_bos_token_id":null,
                "forced_eos_token_id":null,
                "remove_invalid_values":null
            }
        }' \
        $url)

echo $result | jq -r