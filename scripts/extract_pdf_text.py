#!/usr/bin/env python3
"""
PDF Text Extraction Script

Extract text from the CPS GLOSSARY.pdf to understand CMS data access methods.
"""

import PyPDF2
import sys
import os

def extract_pdf_text(pdf_path):
    """
    Extract text from PDF file
    """
    try:
        with open(pdf_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            
            print(f"PDF has {len(pdf_reader.pages)} pages")
            
            full_text = ""
            for page_num, page in enumerate(pdf_reader.pages):
                text = page.extract_text()
                full_text += text
                print(f"\n--- PAGE {page_num + 1} ---")
                print(text[:500] + "..." if len(text) > 500 else text)
            
            return full_text
            
    except Exception as e:
        print(f"Error extracting PDF text: {str(e)}")
        return None

def main():
    """
    Main function to extract PDF text
    """
    pdf_path = "data/raw/CPS GLOSSARY.pdf"
    
    if not os.path.exists(pdf_path):
        print(f"PDF file not found: {pdf_path}")
        return
    
    print("Extracting text from CPS GLOSSARY.pdf...")
    text = extract_pdf_text(pdf_path)
    
    if text:
        print(f"\n{'='*60}")
        print("FULL EXTRACTED TEXT")
        print("=" * 60)
        print(text)
    else:
        print("Failed to extract text from PDF")

if __name__ == "__main__":
    main()
