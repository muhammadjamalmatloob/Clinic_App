import os

directory = r'D:\5th semester\SPM\Clinic_App\frontend\lib'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            target_success = "CustomToast.showSuccess(context, ');"
            target_error = "CustomToast.showError(context, ');"
            
            if target_success in content or target_error in content:
                print(f'Fixing {filepath}')
                content = content.replace(target_success, "CustomToast.showSuccess(context, 'Success');")
                content = content.replace(target_error, "CustomToast.showError(context, 'An error occurred');")
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
print('Fix complete!')
