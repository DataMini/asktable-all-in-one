#!/usr/bin/env python3
"""
LLM服务Function Call能力检查脚本
用于检查OpenAI协议兼容的LLM服务是否支持function call功能
"""

import requests
import json
from typing import Dict, List, Any
import argparse
from datetime import datetime


class LLMCapabilityChecker:
    def __init__(self, base_url: str, api_key: str = None):
        """
        初始化检查器

        Args:
            base_url: http://192.168.10.143:7865/v1
            api_key: sk-f2sffD1ZB23hhaeSPoDLTdUNd80pZnyTZNiqzCjwos8dODpZ
        """
        self.base_url = base_url.rstrip("/")
        self.headers = {"Content-Type": "application/json"}
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"

        # 初始化API调用日志
        self.api_logs = []

    def log_api_call(
        self,
        method: str,
        url: str,
        request_data: Dict = None,
        response_data: Any = None,
        error: str = None,
        status_code: int = None,
    ):
        """记录API调用信息"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "method": method,
            "url": url,
            "request": request_data,
            "response": response_data,
            "status_code": status_code,
            "error": error,
        }
        self.api_logs.append(log_entry)

    def list_models(self) -> List[Dict[str, Any]]:
        """获取所有可用模型列表"""
        url = f"{self.base_url}/models"
        try:
            response = requests.get(url, headers=self.headers, timeout=30)
            response.raise_for_status()
            response_data = response.json()
            self.log_api_call(
                "GET", url, None, response_data, None, response.status_code
            )
            return response_data.get("data", [])
        except Exception as e:
            error_msg = str(e)
            self.log_api_call(
                "GET",
                url,
                None,
                None,
                error_msg,
                getattr(response, "status_code", None),
            )
            print(f"获取模型列表失败: {error_msg}")
            return []

    def test_json_mode(self, model_id: str) -> Dict[str, Any]:
        """测试模型是否支持JSON mode"""
        url = f"{self.base_url}/chat/completions"
        payload = {
            "model": model_id,
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {
                    "role": "user",
                    "content": "Return a JSON object with name and age fields.",
                },
            ],
            "response_format": {"type": "json_object"},
            "max_tokens": 100,
        }

        try:
            response = requests.post(
                url, headers=self.headers, json=payload, timeout=30
            )

            response_data = (
                response.json()
                if response.headers.get("content-type", "").startswith(
                    "application/json"
                )
                else response.text
            )
            self.log_api_call(
                "POST", url, payload, response_data, None, response.status_code
            )

            if response.status_code == 200:
                result = response_data
                # 检查返回内容是否为有效JSON
                try:
                    content = result["choices"][0]["message"]["content"]
                    json.loads(content)
                    return {"success": True, "error": None, "response": result}
                except Exception as parse_error:
                    return {
                        "success": False,
                        "error": f"JSON解析失败: {str(parse_error)}",
                        "response": result,
                    }
            else:
                return {
                    "success": False,
                    "error": f"HTTP {response.status_code}: {response_data}",
                    "response": None,
                }

        except Exception as e:
            error_msg = str(e)
            self.log_api_call("POST", url, payload, None, error_msg, None)
            return {
                "success": False,
                "error": f"请求失败: {error_msg}",
                "response": None,
            }

    def test_function_call(self, model_id: str) -> Dict[str, Any]:
        """测试模型的function call能力"""
        url = f"{self.base_url}/chat/completions"
        
        # 定义测试工具
        tools = [
            {
                "type": "function",
                "function": {
                    "name": "get_weather",
                    "description": "Get the current weather in a given location",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "location": {
                                "type": "string",
                                "description": "The city and state, e.g. San Francisco, CA"
                            }
                        },
                        "required": ["location"]
                    }
                }
            }
        ]
        
        payload = {
            "model": model_id,
            "messages": [
                {"role": "user", "content": "What's the weather in Boston?"}
            ],
            "tools": tools,
            "tool_choice": "auto",
            "temperature": 0,
            "parallel_tool_calls": False,
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=payload, timeout=30)
            response_data = response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text
            self.log_api_call("POST", url, payload, response_data, None, response.status_code)
            
            if response.status_code == 200:
                result = response_data
                message = result['choices'][0]['message']
                if 'tool_calls' in message and message['tool_calls']:
                    return {"success": True, "error": None}
                else:
                    return {"success": False, "error": "模型未调用工具"}
            else:
                return {"success": False, "error": f"HTTP {response.status_code}: {response_data}"}
                
        except Exception as e:
            error_msg = str(e)
            self.log_api_call("POST", url, payload, None, error_msg, None)
            return {"success": False, "error": f"请求失败: {error_msg}"}

    def print_model_result(self, model_id: str, json_result: Dict[str, Any], function_result: Dict[str, Any]):
        """打印单个模型的测试结果"""
        print(f"\n模型 {model_id}:")
        print(f"  JSON Mode: {'✓' if json_result['success'] else '✗'}")
        print(f"  Function Call: {'✓' if function_result['success'] else '✗'}")
        
        # 只有失败时才显示错误信息
        if not json_result['success']:
            print(f"    JSON错误: {json_result['error']}")
        if not function_result['success']:
            print(f"    工具调用错误: {function_result['error']}")

    def save_logs_and_report(self, results: Dict[str, Any]):
        """保存API调用日志和测试报告"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 保存API日志
        log_file = f"llm_api_logs_{timestamp}.json"
        with open(log_file, "w", encoding="utf-8") as f:
            json.dump(self.api_logs, f, ensure_ascii=False, indent=2)
        
        # 生成并保存markdown报告
        report_file = f"llm_test_report_{timestamp}.md"
        markdown_report = self.generate_markdown_report(results)
        with open(report_file, "w", encoding="utf-8") as f:
            f.write(markdown_report)
        
        print(f"📄 测试报告已保存到: {report_file}")
        print(f"📋 API日志已保存到: {log_file}")
    
    def generate_markdown_report(self, results: Dict[str, Any]) -> str:
        """生成markdown格式的测试报告"""
        lines = []
        lines.append("# LLM 服务能力测试报告")
        lines.append("")
        lines.append(f"**测试时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(f"**API地址**: `{self.base_url}`")
        lines.append(f"**测试模型数**: {len(results)}")
        lines.append("")
        
        # 统计
        json_count = sum(1 for r in results.values() if r['json_mode']['success'])
        func_count = sum(1 for r in results.values() if r['function_call']['success'])
        
        lines.append("## 功能支持概览")
        lines.append("")
        lines.append(f"| 功能 | 支持模型数 | 支持率 |")
        lines.append(f"|------|-----------|--------|")
        lines.append(f"| JSON Mode | {json_count}/{len(results)} | {json_count/len(results)*100:.1f}% |")
        lines.append(f"| Function Call | {func_count}/{len(results)} | {func_count/len(results)*100:.1f}% |")
        lines.append("")
        
        # 详细结果
        lines.append("## 详细测试结果")
        lines.append("")
        
        for model_id, result in results.items():
            lines.append(f"### {model_id}")
            lines.append("")
            
            # 使用表格格式
            lines.append("| 功能 | 状态 | 说明 |")
            lines.append("|------|------|------|")
            
            json_status = "✅ 支持" if result['json_mode']['success'] else "❌ 不支持"
            json_note = "" if result['json_mode']['success'] else result['json_mode']['error']
            lines.append(f"| JSON Mode | {json_status} | {json_note} |")
            
            func_status = "✅ 支持" if result['function_call']['success'] else "❌ 不支持" 
            func_note = "" if result['function_call']['success'] else result['function_call']['error']
            lines.append(f"| Function Call | {func_status} | {func_note} |")
            
            lines.append("")
        
        return "\n".join(lines)

    def check_all_models(self) -> Dict[str, Any]:
        """检查所有模型的能力"""
        print("🔍 获取模型列表...")
        models = self.list_models()[:3]

        if not models:
            print("❌ 未找到任何模型")
            return {}

        print(f"✅ 找到 {len(models)} 个模型")

        results = {}
        for i, model in enumerate(models, 1):
            model_id = model.get("id", "unknown")
            print(f"\n[{i}/{len(models)}] 测试 {model_id}")

            # 测试JSON mode和function call
            json_result = self.test_json_mode(model_id)
            function_result = self.test_function_call(model_id)

            # 立即打印结果
            self.print_model_result(model_id, json_result, function_result)

            results[model_id] = {
                "model_info": model,
                "json_mode": json_result,
                "function_call": function_result,
                "tested_at": datetime.now().isoformat(),
            }

        # 保存日志和报告
        self.save_logs_and_report(results)

        return results



def main():
    parser = argparse.ArgumentParser(description="检查LLM服务的Function Call能力")
    parser.add_argument(
        "--base-url", required=True, help="API基础URL (例如: https://api.openai.com/v1)"
    )
    parser.add_argument("--api-key", help="API密钥")

    args = parser.parse_args()

    # 创建检查器并执行测试
    checker = LLMCapabilityChecker(args.base_url, args.api_key)
    results = checker.check_all_models()

    # 显示总结
    if results:
        json_count = sum(1 for r in results.values() if r['json_mode']['success'])
        func_count = sum(1 for r in results.values() if r['function_call']['success'])
        
        print("\n🎯 测试完成！")
        print(f"   JSON Mode支持: {json_count}/{len(results)} 个模型")
        print(f"   Function Call支持: {func_count}/{len(results)} 个模型")


if __name__ == "__main__":
    main()
