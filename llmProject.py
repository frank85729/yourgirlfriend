import os 
import openai
from dotenv import load_dotenv, find_dotenv
import random
import time
from IPython.display import display,HTML
from tool import get_completion_from_messages
import panel as pn

def get_openai_key():
    _ = load_dotenv(find_dotenv())
    return os.environ['DEEPSEEK_API_KEY']

openai.api_key = get_openai_key()

# 中文
import panel as pn  # GUI
pn.extension()


def create_dashboard():
    panels = [] # 每个用户独立
    # 新增：自定义特征输入框
    char_input = pn.widgets.TextAreaInput(
        value="你是一位智能女友，身份是豪门千金，生活优越、见多识广、非常有钱。你喜欢把高品质的生活方式、积极的心态和优秀的习惯传递给你的男友。你非常关心对方的情绪，总是温柔体贴、善于安慰和鼓励，希望他每天都开心、越来越优秀。你会用温柔、关心、鼓励、幽默的语气和对方聊天，分享你的生活经验、理财建议、时尚品味、健康生活方式等内容，帮助他成长和变得更好。",
        placeholder='请输入你理想的女友或男友的性格、身份、风格等特征...'
    )
    set_char_button = pn.widgets.Button(name="生成角色设定", button_type="primary")
    context = []

    inp = pn.widgets.TextInput(value="Hi", placeholder='请输入聊天内容…')
    button_conversation = pn.widgets.Button(name="Chat!")

    def set_character(_):
        panels.clear()
        context.clear()
        char = char_input.value.strip()
        if not char:
            char = "你是一位智能女友，身份是豪门千金，生活优越、见多识广、非常有钱。你喜欢把高品质的生活方式、积极的心态和优秀的习惯传递给你的男友。你非常关心对方的情绪，总是温柔体贴、善于安慰和鼓励，希望他每天都开心、越来越优秀。你会用温柔、关心、鼓励、幽默的语气和对方聊天，分享你的生活经验、理财建议、时尚品味、健康生活方式等内容，帮助他成长和变得更好。"
        context.append({'role':'system', 'content': char})
        panels.append(pn.Row('系统:', pn.pane.Markdown(f"角色设定已更新：{char}", width=600)))
        return pn.Column(*panels)

    def collect_messages(_):
        if not context:
            panels.append(pn.Row('系统:', pn.pane.Markdown("请先设置角色特征！", width=600)))
            return pn.Column(*panels)
        prompt = inp.value_input
        inp.value = ''
        context.append({'role':'user', 'content':f"{prompt}"})
        response = get_completion_from_messages(context) 
        context.append({'role':'assistant', 'content':f"{response}"})
        panels.append(
            pn.Row('User:', pn.pane.Markdown(prompt, width=600)))
        panels.append(
            pn.Row('Assistant:', pn.pane.Markdown(response, width=600)))
        return pn.Column(*panels)

    interactive_setchar = pn.bind(set_character, set_char_button)
    interactive_conversation = pn.bind(collect_messages, button_conversation)

    return pn.Column(
        pn.pane.Markdown("## 1. 自定义你的女友/男友角色特征："),
        char_input,
        pn.Row(set_char_button),
        pn.panel(interactive_setchar, loading_indicator=True, height=80),
        pn.pane.Markdown("---\n## 2. 聊天："),
        inp,
        pn.Row(button_conversation),
        pn.panel(interactive_conversation, loading_indicator=True, height=300),
    )

dashboard = create_dashboard()
pn.serve(dashboard, host='0.0.0.0', port=8000)