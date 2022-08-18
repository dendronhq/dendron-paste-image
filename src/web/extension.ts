import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    const disposable = vscode.commands.registerCommand('extension.pasteImage', () => {
        vscode.window.showWarningMessage("Paste Image is currently not supported in VSCode for the Web");
    });

    context.subscriptions.push(disposable);
}

export function deactivate() {}