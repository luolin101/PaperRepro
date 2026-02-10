"""
Tools for reproducibility evaluation workflow.
"""
import os
import json
import base64
from typing import List, Optional
from research_agent.inno.registry import register_tool
from research_agent.inno.types import Result
import fitz
from docling.document_converter import DocumentConverter


def merge_figures(pictures, max_gap=20):
    """合并同页 bbox 接近的小图，返回合并后的 bbox 列表"""
    merged = []
    for pic in pictures:
        bbox = pic.prov[0].bbox
        page_no = pic.prov[0].page_no
        matched = False
        for m in merged:
            if m["page_no"] != page_no:
                continue
            if (bbox.l - m["r"] < max_gap and bbox.r - m["l"] > -max_gap and
                bbox.b - m["t"] < max_gap and bbox.t - m["b"] > -max_gap):
                m["l"] = min(m["l"], bbox.l)
                m["b"] = min(m["b"], bbox.b)
                m["r"] = max(m["r"], bbox.r)
                m["t"] = max(m["t"], bbox.t)
                matched = True
                break
        if not matched:
            merged.append({"page_no": page_no, "l": bbox.l, "b": bbox.b,
                           "r": bbox.r, "t": bbox.t})
    return merged


@register_tool("pdf_extract_figures_tables")
def pdf_extract_figures_tables(
    pdf_path: str,
    output_dir: str,
    dpi: int = 200,
    margin_x: int = 8,
    margin_y: int = 35,
    merge_gap: int = 20,
    min_width: int = 60,
    min_height: int = 60,
    header_footer_margin: int = 10
) -> str:
    """
    Extract figures and tables from a PDF file and save them as images.
    
    Args:
        pdf_path: Path to the PDF file
        output_dir: Directory to save extracted images (REQUIRED - must be specified, cannot be empty)
        dpi: Resolution for image extraction (default: 200)
        margin_x: Horizontal margin around elements (default: 8)
        margin_y: Vertical margin around elements (default: 35)
        merge_gap: Maximum gap to merge nearby figures (default: 20)
        min_width: Minimum width to keep a figure (default: 50)
        min_height: Minimum height to keep a figure (default: 50)
        header_footer_margin: Margin to filter out header/footer (default: 50)
    
    Returns:
        A summary string listing all extracted figures and tables with their paths
    """
    if not output_dir or not output_dir.strip():
        return "Error: output_dir parameter is required and cannot be empty. Please specify a valid directory path."
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Docling 获取元素位置
    converter = DocumentConverter()
    result = converter.convert(pdf_path)
    doc = result.document
    
    pdf = fitz.open(pdf_path)
    
    extracted_items = []
    
    # 表格截图
    for idx, tbl in enumerate(doc.tables, start=1):
        page_num = tbl.prov[0].page_no if tbl.prov else 1
        bbox = tbl.prov[0].bbox if tbl.prov else None
        page = pdf[page_num - 1]
        
        if bbox:
            l, b, r, t = bbox.l, bbox.b, bbox.r, bbox.t
            rect = fitz.Rect(
                max(0, l - margin_x),
                max(0, page.rect.height - t - margin_y),
                min(page.rect.width, r + margin_x),
                min(page.rect.height, page.rect.height - b + margin_y)
            )
        else:
            rect = fitz.Rect(0, 0, 100, 100)
        
        pix = page.get_pixmap(clip=rect, dpi=dpi)
        filename = os.path.join(output_dir, f"table_{idx}_page{page_num}.png")
        pix.save(filename)
        extracted_items.append(f"Table {idx} (page {page_num}): {filename}")
    
    # Figure 截图（合并 + 过滤小图 / 页眉页脚）
    merged_figs = merge_figures(doc.pictures, max_gap=merge_gap)
    filtered_figs = []
    for f in merged_figs:
        page_num = f["page_no"]
        page = pdf[page_num - 1]
        width = f["r"] - f["l"]
        height = f["t"] - f["b"]
        
        # 过滤小图或页眉页脚
        if width < min_width or height < min_height:
            continue
        if f["b"] < header_footer_margin or f["t"] > (page.rect.height - header_footer_margin):
            continue
        filtered_figs.append(f)
    
    # 保存 Figure
    for idx, f in enumerate(filtered_figs, start=1):
        page = pdf[f["page_no"] - 1]
        rect = fitz.Rect(
            max(0, f["l"] - margin_x),
            max(0, page.rect.height - f["t"] - margin_y),
            min(page.rect.width, f["r"] + margin_x),
            min(page.rect.height, page.rect.height - f["b"] + margin_y)
        )
        pix = page.get_pixmap(clip=rect, dpi=dpi)
        filename = os.path.join(output_dir, f"figure_{idx}_page{f['page_no']}.png")
        pix.save(filename)
        extracted_items.append(f"Figure {idx} (page {f['page_no']}): {filename}")
    
    pdf.close()
    
    summary = f"Extracted {len([x for x in extracted_items if x.startswith('Table')])} tables and {len([x for x in extracted_items if x.startswith('Figure')])} figures:\n"
    summary += "\n".join(extracted_items)
    return summary


@register_tool("vlm_query_images")
def vlm_query_images(
    image_paths: List[str],
    query: str,
) -> str:
    """
    Query a Vision Language Model (VLM) about images.
    
    **IMPORTANT**: This tool ONLY accepts image files. Non-image files (like .tex, .csv, .txt, etc.) should NOT be passed to this tool.
    For non-image files, read their content and include it in the query text instead.
    
    Args:
        image_paths: List of paths to image files ONLY (e.g., .png, .jpg, .jpeg, .pdf images, etc.)
        query: Question or instruction about the images
    
    Returns:
        Response from the VLM about the images
    """
    # Valid image extensions
    VALID_IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'}
    
    try:
        from litellm import completion
        
        # Validate that all paths are image files
        invalid_files = []
        for img_path in image_paths:
            if not os.path.exists(img_path):
                invalid_files.append(f"{img_path} (file does not exist)")
                continue
            
            ext = os.path.splitext(img_path)[1].lower()
            if ext not in VALID_IMAGE_EXTENSIONS:
                invalid_files.append(f"{img_path} (not an image file, extension: {ext})")
        
        if invalid_files:
            return f"Error: vlm_query_images only accepts image files. Invalid files:\n" + "\n".join(f"  - {f}" for f in invalid_files)
        
        # Prepare messages with images
        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": query}
                ]
            }
        ]
        
        # Add images to content
        for img_path in image_paths:
            if os.path.exists(img_path):
                import base64
                with open(img_path, "rb") as img_file:
                    img_data = base64.b64encode(img_file.read()).decode('utf-8')
                    # Determine image type from extension
                    ext = os.path.splitext(img_path)[1].lower()
                    mime_type = f"image/{ext[1:]}" if ext else "image/png"
                    messages[0]["content"].append({
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{mime_type};base64,{img_data}"
                        }
                    })
        
        response = completion(
            model="gpt-4o",
            messages=messages
        )
        
        return response.choices[0].message.content
    except Exception as e:
        return f"Error querying VLM: {str(e)}"


@register_tool("add_image_to_context")
def add_image_to_context(
    image_path: str,
    description: Optional[str] = None
) -> Result:
    """
    Add an image to the conversation context by encoding it as base64.
    
    **IMPORTANT**: This tool is designed for multimodal models. When called, the image will be automatically 
    included in the message content, allowing the multimodal model to process it directly.
    
    **USE CASE**: If the agent's model supports multimodal input (e.g., GPT-4 Vision, Claude 3.5 Sonnet with vision),
    you can use this tool to add images to the conversation context. After calling this tool, the image will be 
    available in the message history for the model to analyze.
    
    Args:
        image_path: Path to the image file (e.g., .png, .jpg, .jpeg, .gif, .bmp, .webp)
        description: Optional text description to accompany the image (default: "Image has been added to context")
    
    Returns:
        Result object containing:
        - value: Text message confirming the image was added
        - image: Base64-encoded image data (automatically included in message)
    """
    # Valid image extensions
    VALID_IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'}
    
    try:
        # Validate file exists
        if not os.path.exists(image_path):
            return Result(
                value=f"Error: Image file not found: {image_path}",
                image=None
            )
        
        # Validate file extension
        ext = os.path.splitext(image_path)[1].lower()
        if ext not in VALID_IMAGE_EXTENSIONS:
            return Result(
                value=f"Error: {image_path} is not a valid image file. Supported formats: {', '.join(VALID_IMAGE_EXTENSIONS)}",
                image=None
            )
        
        # Read and encode image as base64
        with open(image_path, "rb") as img_file:
            img_data = base64.b64encode(img_file.read()).decode('utf-8')
        
        # Determine MIME type from extension
        mime_type_map = {
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.gif': 'image/gif',
            '.bmp': 'image/bmp',
            '.webp': 'image/webp'
        }
        mime_type = mime_type_map.get(ext, 'image/png')
        
        # Create description message
        if description is None:
            description = f"Image from {image_path} has been added to context. The image is now available for the multimodal model to analyze."
        else:
            description = f"{description}\n\nImage from {image_path} has been added to context. The image is now available for the multimodal model to analyze."
        
        # Return Result with base64 image
        # The image will be automatically added to the message content by the core system
        return Result(
            value=description,
            image=img_data  # Base64-encoded image, will be included in message as image_url
        )
        
    except Exception as e:
        return Result(
            value=f"Error adding image to context: {str(e)}",
            image=None
        )


@register_tool("save_reproducibility_score")
def save_reproducibility_score(
    score: int,
    output_path: str = "reproducibility_score.json"
) -> str:
    """
    Save the reproducibility score to a JSON file.
    
    Args:
        score: Reproducibility score (1, 2, 3, or 4)
        output_path: Path to save the score file (default: "reproducibility_score.json")
    
    Returns:
        Confirmation message
    """
    if score not in [1, 2, 3, 4]:
        return f"Error: Score must be 1, 2, 3, or 4. Got {score}"
    
    data = {"reproducibility_score": score}
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    
    return f"Reproducibility score {score} saved to {output_path}"

